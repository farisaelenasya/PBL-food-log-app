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
        $userId = auth()->id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'User belum login'
            ], 401);
        }


        $logs = FoodLog::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get();


        return response()->json([
            'success' => true,
            'data' => $logs
        ]);
    }



    public function store(Request $request)
    {

        $userId = auth()->id();


        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'User belum login'
            ], 401);
        }



        try {


            $foodLog = FoodLog::create([

                'user_id' => $userId,

                'nama_makanan' => $request->nama_makanan,
                'gram' => $request->gram,
                'waktu_makan' => $request->waktu_makan,

                'kalori' => $request->kalori,
                'karbo' => $request->karbo,
                'protein' => $request->protein,
                'lemak' => $request->lemak,
                'serat' => $request->serat,
                'gula' => $request->gula,

                'indeks_glikemik' => $request->indeks_glikemik,
                'foto_path' => $request->foto_path,
                'dicatat_pada' => $request->dicatat_pada,

            ]);





            // ==========================
            // TAMBAH POIN +10 USER LOGIN
            // ==========================

            $points = DB::table('user_points')
                ->where('user_id', $userId)
                ->first();



            if ($points) {


                DB::table('user_points')
                    ->where('user_id', $userId)
                    ->increment('total_poin', 10);


            } else {


                DB::table('user_points')
                    ->insert([
                        'user_id' => $userId,
                        'total_poin' => 10,
                        'level_user' => 1,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);

            }





            // ==========================
            // HITUNG LEVEL
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



   public function adminFoodLogs()
{
    $logs = FoodLog::with('user')
        ->orderBy('created_at','desc')
        ->take(20)
        ->get();


    return response()->json([
        'success'=>true,
        'data'=>$logs
    ]);
}

    public function show($id)
    {

        $userId = auth()->id();


        $foodLog = FoodLog::where('user_id', $userId)
            ->find($id);



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

        $userId = auth()->id();



        $foodLog = FoodLog::where('user_id', $userId)
            ->find($id);



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

        $userId = auth()->id();


        if (!$userId) {

            return response()->json([
                'success'=>false,
                'message'=>'User belum login'
            ],401);

        }



        $points = DB::table('user_points')
            ->where('user_id', $userId)
            ->first();



        if (!$points) {


            return response()->json([

                'success'=>true,

                'data'=>[
                    'user_id'=>$userId,
                    'total_poin'=>0,
                    'level_user'=>1
                ]

            ]);

        }



        return response()->json([
            'success'=>true,
            'data'=>$points
        ]);

    }





    public function getDailySugar(Request $request)
    {

        $userId = auth()->id();


        if (!$userId) {

            return response()->json([
                'success'=>false,
                'message'=>'User belum login'
            ],401);

        }



        $today = Carbon::today();



        $totalGula = FoodLog::where('user_id',$userId)
            ->whereDate('created_at',$today)
            ->sum('gula');



        $limit = 25;



        return response()->json([

            'success'=>true,

            'data'=>[

                'total_gula'=>$totalGula,

                'limit'=>$limit,

                'warning'=>$totalGula > $limit,

                'date'=>$today->toDateString()

            ]

        ]);

    }

}