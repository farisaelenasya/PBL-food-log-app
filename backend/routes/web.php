<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Route untuk serve foto profil dengan CORS header
Route::get('/foto/{filename}', function ($filename) {
    $path = storage_path('app/public/foto_profil/' . $filename);
    
    if (!file_exists($path)) {
        return response()->json(['error' => 'File not found'], 404);
    }
    
    return response()->file($path, [
        'Access-Control-Allow-Origin' => '*'
    ]);
});