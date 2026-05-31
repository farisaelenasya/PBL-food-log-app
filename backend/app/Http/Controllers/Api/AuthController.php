<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Cache;
use App\Mail\OtpMail;


class AuthController extends Controller
{
   public function register(Request $request)
{
    $request->validate([
        'name'          => 'required',
        'email'         => 'required|email|unique:users',
        'password'      => 'required|min:8',
        'tanggal_lahir' => 'nullable|date',
        'umur'          => 'nullable|integer',
        'tinggi_badan'  => 'nullable|integer',
        'berat_badan'   => 'nullable|integer',
        'jenis_kelamin' => 'nullable|in:Laki-laki,Perempuan',
        'tipe_diabetes' => 'nullable|in:Tipe 1,Tipe 2,Gestasional,Pra-Diabetes',
    ]);

    $user = User::create([
        'name'          => $request->name,
        'email'         => $request->email,
        'password'      => Hash::make($request->password),
        'tanggal_lahir' => $request->tanggal_lahir,
        'umur'          => $request->umur,
        'tinggi_badan'  => $request->tinggi_badan,
        'berat_badan'   => $request->berat_badan,
        'jenis_kelamin' => $request->jenis_kelamin,
        'tipe_diabetes' => $request->tipe_diabetes,
    ]);

    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'status'  => true,
        'message' => 'Register berhasil',
        'token'   => $token,
        'user'    => $user
    ]);
}

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'status' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        $user = Auth::user();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Login berhasil',
            'token' => $token,
            'user' => $user
        ]);
    }

    public function kirimOtp(Request $request)
{
    $request->validate([
        'email' => 'required|email|unique:users,email',
    ]);

    $otp = strval(random_int(100000, 999999));

    // Simpan OTP di cache selama 5 menit
    Cache::put('otp_' . $request->email, $otp, now()->addMinutes(5));

    Mail::to($request->email)->send(new OtpMail($otp));

    return response()->json([
        'status'  => true,
        'message' => 'OTP berhasil dikirim',
    ]);
}

public function verifikasiOtp(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'otp'   => 'required',
    ]);

    $otpCache = Cache::get('otp_' . $request->email);

    if (!$otpCache || $otpCache !== $request->otp) {
        return response()->json([
            'status'  => false,
            'message' => 'Kode OTP salah atau sudah kadaluarsa',
        ], 422);
    }

    Cache::forget('otp_' . $request->email);

    return response()->json([
        'status'  => true,
        'message' => 'OTP valid',
    ]);
}
}