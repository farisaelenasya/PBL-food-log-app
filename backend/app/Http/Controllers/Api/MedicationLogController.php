<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MedicationLog;
use Illuminate\Http\Request;

class MedicationLogController extends Controller
{
    public function index(Request $request)
    {
        $logs = MedicationLog::where('user_id', $request->user()->id)
            ->with('medication')
            ->orderBy('waktu_aksi', 'desc')
            ->get();

        return response()->json($logs);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'medication_id' => 'required|exists:medications,id',
            'status' => 'required|in:diminum,ditunda',
            'tunda_sampai' => 'nullable|date',
        ]);

        $log = MedicationLog::create([
            'user_id' => $request->user()->id,
            'medication_id' => $validated['medication_id'],
            'status' => $validated['status'],
            'waktu_aksi' => now(),
            'tunda_sampai' => $validated['tunda_sampai'] ?? null,
        ]);

        return response()->json([
            'message' => 'Log berhasil disimpan',
            'data' => $log,
        ], 201);
    }
}