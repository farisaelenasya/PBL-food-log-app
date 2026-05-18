<?php

namespace App\Http\Controllers;

use App\Models\Glucose;
use Illuminate\Http\Request;

class GlucoseController extends Controller
{
    public function index()
    {
        return response()->json([
            'status' => 'success',
            'message' => 'API berjalan'
        ]);
    }

    public function store(Request $request)
    {
        $glucose = Glucose::create($request->all());

        return response()->json($glucose, 201);
    }
}