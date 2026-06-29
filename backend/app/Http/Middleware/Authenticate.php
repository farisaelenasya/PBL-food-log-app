<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    protected function redirectTo(Request $request): ?string
    {
        // TAMBAH INI — return null untuk API request
        if ($request->expectsJson()) {
            return null;
        }
        return null; // jangan redirect ke 'login'
    }
}