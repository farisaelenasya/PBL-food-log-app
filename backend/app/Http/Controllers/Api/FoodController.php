<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Food;

class FoodController extends Controller
{
    public function search(Request $request)
    {
        // SAMAKAN DENGAN FLUTTER
        $query = $request->query('q');

        $foods = Food::where(
            'nama',
            'like',
            "%$query%"
        )->get();

        return response()->json($foods);
    }

    public function all()
    {
        return response()->json(Food::all());
    }
}