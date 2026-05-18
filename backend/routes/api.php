<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GlucoseController;

Route::apiResource('glucoses', GlucoseController::class);