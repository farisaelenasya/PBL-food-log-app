<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GlucoseController;
use App\Http\Controllers\Api\AuthController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/kirim-otp',     [AuthController::class, 'kirimOtp']);
Route::post('/verifikasi-otp', [AuthController::class, 'verifikasiOtp']);
Route::apiResource('glucoses', GlucoseController::class);