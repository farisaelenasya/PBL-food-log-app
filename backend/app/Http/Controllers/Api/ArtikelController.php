<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artikel;
use Illuminate\Http\Request;

class ArtikelController extends Controller
{
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => Artikel::latest()->get()
        ]);
    }

    public function store(Request $request)
    {
        $artikel = Artikel::create([
            'judul' => $request->judul,
            'kategori' => $request->kategori,
            'isi' => $request->isi,
            'link_artikel' => $request->link_artikel,
            'diterbitkan' => true,
        ]);

        return response()->json([
            'success' => true,
            'data' => $artikel
        ]);
    }

    public function destroy($id)
    {
        Artikel::findOrFail($id)->delete();

        return response()->json([
            'success' => true
        ]);
    }
}