<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GlucoseController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MedicationController;
use App\Http\Controllers\Api\ProfileController;        // ← tambah ini


Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('medications', MedicationController::class);
    Route::get('profile', [ProfileController::class, 'show']);
Route::put('profile', [ProfileController::class, 'update']);
Route::post('/profile', [ProfileController::class, 'update']);
});
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/kirim-otp',     [AuthController::class, 'kirimOtp']);
Route::post('/verifikasi-otp', [AuthController::class, 'verifikasiOtp']);
Route::apiResource('glucoses', GlucoseController::class);