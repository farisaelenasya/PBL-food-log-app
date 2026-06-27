<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Glucose;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class AdminController extends Controller
{
    private function cekAdmin()
    {
        if (Auth::user()->role !== 'admin') {
            abort(403, 'Akses ditolak. Hanya admin yang bisa mengakses fitur ini.');
        }
    }

    // GET /api/admin/patients
    public function patients()
    {
        $this->cekAdmin();

        $pasien = User::where('role', 'user')
            ->select('id', 'name', 'email', 'jenis_kelamin', 'umur', 'tipe_diabetes')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $pasien,
        ]);
    }

    // GET /api/admin/patients/{id}/glucose
    public function patientGlucose($id)
    {
        $this->cekAdmin();

        $pasien = User::where('role', 'user')->findOrFail($id);

        $data = Glucose::where('user_id', $pasien->id)
            ->latest()
            ->get()
            ->map(function ($item) {
                $item->status = $this->statusGlukosa($item->glucose_level);
                return $item;
            });

        return response()->json([
            'status' => 'success',
            'pasien' => [
                'id' => $pasien->id,
                'name' => $pasien->name,
                'jenis_kelamin' => $pasien->jenis_kelamin,
                'umur' => $pasien->umur,
                'tipe_diabetes' => $pasien->tipe_diabetes,
            ],
            'data' => $data,
        ]);
    }

    private function statusGlukosa(int $level): string
    {
        if ($level < 70) return 'RENDAH';
        if ($level <= 125) return 'NORMAL';
        return 'TINGGI';
    }
}