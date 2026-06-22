<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GlucoseController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MedicationController;
use App\Http\Controllers\Api\ProfileController;      
use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\Api\FoodLogController;
use App\Http\Controllers\Api\FoodVisionController;
use App\Http\Controllers\Api\PointController;
use App\Http\Controllers\Api\ArtikelController;

Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('medications', MedicationController::class);
    Route::get('profile', [ProfileController::class, 'show']);
    Route::put('profile', [ProfileController::class, 'update']);
    Route::post('/profile', [ProfileController::class, 'update']);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/kirim-otp', [AuthController::class, 'kirimOtp']);
Route::post('/verifikasi-otp', [AuthController::class, 'verifikasiOtp']);

Route::apiResource('glucoses', GlucoseController::class);

Route::get('/foods', [FoodController::class, 'all']);
Route::get('/foods/search', [FoodController::class, 'search']);

Route::post('/food-logs', [FoodLogController::class, 'store']);
Route::get('/food-logs', [FoodLogController::class, 'index']);

Route::post('/detect-food', [FoodVisionController::class, 'detectFood']);

Route::get('/points', [FoodLogController::class, 'getPoints']);
Route::get('/points/history', [FoodLogController::class, 'pointHistory']);

// ARTIKEL
Route::get('/artikel', [ArtikelController::class, 'index']);
Route::post('/artikel', [ArtikelController::class, 'store']);
Route::delete('/artikel/{id}', [ArtikelController::class, 'destroy']);