<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\FoodLog;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;


class FoodLogController extends Controller
{
    public function index()
    {
        $logs = FoodLog::orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $logs
        ]);
    }

    public function store(Request $request)
    {
        try {

            $foodLog = FoodLog::create([
                'nama_makanan'    => $request->nama_makanan,
                'gram'            => $request->gram,
                'waktu_makan'     => $request->waktu_makan,

                'kalori'          => $request->kalori,
                'karbo'           => $request->karbo,
                'protein'         => $request->protein,
                'lemak'           => $request->lemak,
                'serat'           => $request->serat,
                'gula'            => $request->gula,

                'indeks_glikemik' => $request->indeks_glikemik,
                'foto_path'       => $request->foto_path,
                'dicatat_pada'    => $request->dicatat_pada,
            ]);

         
            //TAMBAH POIN +10
           
            DB::table('user_points')
                ->where('user_id', 1)
                ->increment('total_poin', 10);

           
            // HITUNG LEVEL
           
            $totalPoin = DB::table('user_points')
                ->where('user_id', 1)
                ->value('total_poin');

            $level = floor($totalPoin / 200) + 1;

            DB::table('user_points')
                ->where('user_id', 1)
                ->update([
                    'level_user' => $level
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Food log berhasil disimpan',
                'point_didapat' => 10,
                'total_poin' => $totalPoin,
                'level' => $level,
                'data' => $foodLog
            ], 201);

        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $foodLog = FoodLog::find($id);

        if (!$foodLog) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $foodLog
        ]);
    }

    public function destroy($id)
    {
        $foodLog = FoodLog::find($id);

        if (!$foodLog) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ], 404);
        }

        $foodLog->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data berhasil dihapus'
        ]);
    }

   public function getPoints()
{
    $points = DB::table('user_points')
        ->where('user_id', 1)
        ->first();

    if (!$points) {
        return response()->json([
            'success' => true,
            'data' => [
                'user_id' => 1,
                'total_poin' => 0,
                'level_user' => 1
            ]
        ]);
    }

    return response()->json([
        'success' => true,
        'data' => $points
    ]);
}
    public function getDailySugar(Request $request)
     {
        $userId = $request->user()->id ?? 1; // sementara kalau belum auth

        $today = Carbon::today();

        $totalGula = FoodLog::whereDate('created_at', $today)
        ->sum('gula');

        $limit = 25;

        return response()->json([
            'success' => true,
            'data' => [
            'total_gula' => $totalGula,
            'limit' => $limit,
            'warning' => $totalGula > $limit,
            'date' => $today->toDateString()
        ]
     ]);
    }
}