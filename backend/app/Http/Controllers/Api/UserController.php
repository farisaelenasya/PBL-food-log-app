<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;

class UserController extends Controller
{
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => User::where('role', 'user')->get()
        ]);
    }
}