<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MedicationResource;
use App\Models\Medication;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MedicationController extends Controller
{
    public function index(): JsonResponse
    {
        $medications = Medication::where('user_id', Auth::id())
            ->latest()
            ->get();

        return response()->json([
            'status' => true,
            'data'   => MedicationResource::collection($medications),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'nama_obat'      => 'required|string|max:255',
            'dosis'          => 'nullable|string|max:100',
            'frekuensi'      => 'required|string',
            'waktu_konsumsi' => 'required|string|max:500',
            'tipe'           => 'required|in:jam,makan',
            'catatan'        => 'nullable|string|max:1000',
        ]);

        $medication = Medication::create([
            'user_id'        => Auth::id(),
            'nama_obat'      => $request->nama_obat,
            'dosis'          => $request->dosis ?? '-',
            'frekuensi'      => $request->frekuensi,
            'waktu_konsumsi' => $request->waktu_konsumsi,
            'tipe'           => $request->tipe,
            'catatan'        => $request->catatan ?? '',
        ]);

        return response()->json([
            'status'  => true,
            'message' => 'Obat berhasil disimpan',
            'data'    => new MedicationResource($medication),
        ], 201);
    }

    public function show($id): JsonResponse
    {
        $medication = Medication::where('user_id', Auth::id())->find($id);

        if (!$medication) {
            return response()->json([
                'status'  => false,
                'message' => 'Obat tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'status' => true,
            'data'   => new MedicationResource($medication),
        ]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $medication = Medication::where('user_id', Auth::id())->find($id);

        if (!$medication) {
            return response()->json([
                'status'  => false,
                'message' => 'Obat tidak ditemukan',
            ], 404);
        }

        $request->validate([
            'nama_obat'      => 'sometimes|required|string|max:255',
            'dosis'          => 'nullable|string|max:100',
            'frekuensi'      => 'sometimes|required|string',
            'waktu_konsumsi' => 'sometimes|required|string|max:500',
            'tipe'           => 'sometimes|required|in:jam,makan',
            'catatan'        => 'nullable|string|max:1000',
        ]);

        $medication->update($request->only([
            'nama_obat',
            'dosis',
            'frekuensi',
            'waktu_konsumsi',
            'tipe',
            'catatan',
        ]));

        return response()->json([
            'status'  => true,
            'message' => 'Obat berhasil diperbarui',
            'data'    => new MedicationResource($medication->fresh()),
        ]);
    }

    public function destroy($id): JsonResponse
    {
        $medication = Medication::where('user_id', Auth::id())->find($id);

        if (!$medication) {
            return response()->json([
                'status'  => false,
                'message' => 'Obat tidak ditemukan',
            ], 404);
        }

        $medication->delete();

        return response()->json([
            'status'  => true,
            'message' => 'Obat berhasil dihapus',
        ]);
    }
}