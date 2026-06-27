<?php

namespace App\Http\Controllers;

use App\Models\Glucose;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class GlucoseController extends Controller
{
    public function index()
    {
        $data = Glucose::where('user_id', auth()->id())
            ->latest()
            ->get();

        $data = $data->map(function ($item) {
            $item->status = $this->statusGlukosa($item->glucose_level);
            $item->kategori = $this->kategoriWHO($item->glucose_level);
            return $item;
        });

        return response()->json([
            'status' => 'success',
            'data' => $data
        ]);
    }

    public function store(Request $request)
    {
        Log::info('Data masuk:', $request->all());

        $validated = $request->validate([
            'glucose_level' => 'required|integer|min:1',
        ]);

        $validated['user_id'] = auth()->id();
        $validated['patient_name'] = auth()->user()->name;

        $glucose = Glucose::create($validated);

        $glucose->status = $this->statusGlukosa($glucose->glucose_level);
        $glucose->kategori = $this->kategoriWHO($glucose->glucose_level);

        return response()->json($glucose, 201);
    }

    private function statusGlukosa(int $level): string
    {
        if ($level < 70) return 'Rendah';
        if ($level <= 99) return 'Normal';
        if ($level <= 125) return 'Pra-Diabetes';
        if ($level <= 199) return 'Diabetes';
        return 'Diabetes Kritis';
    }

    private function kategoriWHO(int $level): array
    {
        if ($level < 70) {
            return [
                'label' => 'Hipoglikemia',
                'warna' => '#FF6B35',
                'keterangan' => 'Gula darah terlalu rendah (<70 mg/dL). Segera konsumsi makanan/minuman manis.',
                'tindakan' => 'Konsumsi 15-20g karbohidrat cepat serap'
            ];
        } elseif ($level <= 99) {
            return [
                'label' => 'Normal (Puasa)',
                'warna' => '#4CAF50',
                'keterangan' => 'Gula darah normal saat puasa (70-99 mg/dL) sesuai standar WHO.',
                'tindakan' => 'Pertahankan pola makan sehat'
            ];
        } elseif ($level <= 125) {
            return [
                'label' => 'Pra-Diabetes',
                'warna' => '#FFA726',
                'keterangan' => 'Gula darah puasa terganggu (100-125 mg/dL). Risiko diabetes meningkat.',
                'tindakan' => 'Ubah gaya hidup, kurangi gula dan karbohidrat'
            ];
        } elseif ($level <= 199) {
            return [
                'label' => 'Diabetes',
                'warna' => '#F44336',
                'keterangan' => 'Gula darah tinggi (126-199 mg/dL). Memenuhi kriteria diabetes WHO.',
                'tindakan' => 'Segera konsultasi dokter'
            ];
        } else {
            return [
                'label' => 'Diabetes Kritis',
                'warna' => '#B71C1C',
                'keterangan' => 'Gula darah sangat tinggi (≥200 mg/dL). Kondisi darurat medis.',
                'tindakan' => 'Segera ke IGD atau hubungi dokter'
            ];
        }
    }
}