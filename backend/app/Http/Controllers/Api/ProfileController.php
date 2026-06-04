<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'status' => true,
            'user'   => [
                'id'             => $user->id,
                'name'           => $user->name,
                'email'          => $user->email,
                'tanggal_lahir'  => $user->tanggal_lahir,
                'umur'           => $user->umur,
                'tinggi_badan'   => $user->tinggi_badan,
                'berat_badan'    => $user->berat_badan,
                'jenis_kelamin'  => $user->jenis_kelamin,
                'tipe_diabetes'  => $user->tipe_diabetes,
                'no_telepon'     => $user->no_telepon,
                'golongan_darah' => $user->golongan_darah,
                'foto_profil'    => $user->foto_profil  // ← TAMBAH
                ? url('foto/' . basename($user->foto_profil))
                    : null,
                'created_at'     => $user->created_at,
                'updated_at'     => $user->updated_at,
            ],
        ]);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name'            => 'sometimes|string|max:255',
            'email'           => ['sometimes', 'email', Rule::unique('users')->ignore($user->id)],
            'tanggal_lahir'   => 'sometimes|nullable|date',
            'umur'            => 'sometimes|nullable|integer|min:1|max:120',
            'tinggi_badan'    => 'sometimes|nullable|integer|min:50|max:300',
            'berat_badan'     => 'sometimes|nullable|integer|min:10|max:500',
            'jenis_kelamin'   => 'sometimes|nullable|in:Laki-laki,Perempuan',
            'tipe_diabetes'   => 'sometimes|nullable|in:Tipe 1,Tipe 2,Gestasional,Pra-Diabetes',
            'no_telepon'      => 'sometimes|nullable|string|max:20',
            'golongan_darah'  => 'sometimes|nullable|in:A+,A-,B+,B-,AB+,AB-,O+,O-',
            'password'        => 'sometimes|nullable|string|min:8|confirmed',
            'foto_profil'     => 'sometimes|nullable|image|mimes:jpg,jpeg,png|max:2048', // ← TAMBAH
        ]);

        $user->fill($validated);

        if (!empty($validated['password'])) {
            $user->password = Hash::make($validated['password']);
        }

        // ── Simpan foto jika ada ──────────────────────────
        if ($request->hasFile('foto_profil')) {
            // Hapus foto lama kalau ada
            if ($user->foto_profil) {
                Storage::disk('public')->delete($user->foto_profil);
            }
            $path = $request->file('foto_profil')->store('foto_profil', 'public');
            $user->foto_profil = $path;
        }
        // ─────────────────────────────────────────────────

        $user->save();

        return response()->json([
            'status'  => true,
            'message' => 'Profil berhasil diperbarui',
            'user'    => [
                'id'             => $user->id,
                'name'           => $user->name,
                'email'          => $user->email,
                'tanggal_lahir'  => $user->tanggal_lahir,
                'umur'           => $user->umur,
                'tinggi_badan'   => $user->tinggi_badan,
                'berat_badan'    => $user->berat_badan,
                'jenis_kelamin'  => $user->jenis_kelamin,
                'tipe_diabetes'  => $user->tipe_diabetes,
                'no_telepon'     => $user->no_telepon,
                'golongan_darah' => $user->golongan_darah,
                'foto_profil'    => $user->foto_profil  // ← TAMBAH
                    ? url('/foto/' . basename($user->foto_profil))
                    : null,
                'updated_at'     => $user->updated_at,
            ],
        ]);
    }
}