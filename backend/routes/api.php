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
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\MedicationLogController;

Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('medications', MedicationController::class);
    Route::post('/medication-logs', [MedicationLogController::class, 'store']);
    Route::get('/medication-logs', [MedicationLogController::class, 'index']);
    Route::get('profile', [ProfileController::class, 'show']);
    Route::put('profile', [ProfileController::class, 'update']);
    Route::post('/profile', [ProfileController::class, 'update']);
    Route::apiResource('glucoses', GlucoseController::class);
    Route::apiResource('admin/patients', AdminController::class);
    Route::get('/admin/patients/{id}/glucose', [AdminController::class, 'patientGlucose']);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/kirim-otp', [AuthController::class, 'kirimOtp']);
Route::post('/verifikasi-otp', [AuthController::class, 'verifikasiOtp']);

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

// USER
Route::get('/users', [UserController::class, 'index']);