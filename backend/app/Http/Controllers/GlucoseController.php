<?php

namespace App\Http\Controllers;

use App\Models\Glucose;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
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
            'konteks_makan' => 'nullable|string',
            'catatan' => 'nullable|string',
        ]);


        $userId = auth()->id();


        $validated['user_id'] = $userId;
        $validated['patient_name'] = auth()->user()->name;


        $glucose = Glucose::create($validated);


        $glucose->status = $this->statusGlukosa($glucose->glucose_level);
        $glucose->kategori = $this->kategoriWHO($glucose->glucose_level);



        // ==========================
        // TAMBAH POIN USER LOGIN +10
        // ==========================

        DB::table('user_points')
            ->updateOrInsert(
                [
                    'user_id' => $userId
                ],
                [
                    'total_poin' => DB::raw('COALESCE(total_poin,0) + 10')
                ]
            );


        // ==========================
        // HITUNG LEVEL USER
        // ==========================

        $totalPoin = DB::table('user_points')
            ->where('user_id', $userId)
            ->value('total_poin');


        $level = floor($totalPoin / 200) + 1;


        DB::table('user_points')
            ->where('user_id', $userId)
            ->update([
                'level_user' => $level
            ]);



        return response()->json([
            'point_didapat' => 10,
            'total_poin' => $totalPoin,
            'level' => $level,
            'data' => $glucose,
        ], 201);
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
                'label'=>'Hipoglikemia',
                'warna'=>'#FF6B35',
                'keterangan'=>'Gula darah terlalu rendah (<70 mg/dL).',
                'tindakan'=>'Konsumsi 15-20g karbohidrat cepat serap'
            ];
        }

        elseif ($level <= 99) {
            return [
                'label'=>'Normal (Puasa)',
                'warna'=>'#4CAF50',
                'keterangan'=>'Gula darah normal.',
                'tindakan'=>'Pertahankan pola makan sehat'
            ];
        }

        elseif ($level <=125) {
            return [
                'label'=>'Pra-Diabetes',
                'warna'=>'#FFA726',
                'keterangan'=>'Risiko diabetes meningkat.',
                'tindakan'=>'Kurangi gula dan karbohidrat'
            ];
        }

        elseif ($level <=199) {
            return [
                'label'=>'Diabetes',
                'warna'=>'#F44336',
                'keterangan'=>'Gula darah tinggi.',
                'tindakan'=>'Konsultasi dokter'
            ];
        }


        return [
            'label'=>'Diabetes Kritis',
            'warna'=>'#B71C1C',
            'keterangan'=>'Gula darah sangat tinggi.',
            'tindakan'=>'Segera hubungi dokter'
        ];
    }
}