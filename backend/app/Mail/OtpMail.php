<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public string $otp;

    public function __construct(string $otp)
    {
        $this->otp = $otp;
    }

    public function build(): self
    {
        return $this->subject('Kode OTP Food Log App')
                    ->html("
                        <div style='font-family:sans-serif;padding:24px;max-width:480px;margin:auto;border:1px solid #e0e0e0;border-radius:12px;'>
                            <h2 style='color:#1A73E8;'>Food Log App</h2>
                            <p>Halo! Berikut kode OTP untuk registrasi akun kamu:</p>
                            <div style='font-size:36px;font-weight:bold;letter-spacing:12px;color:#1A2340;text-align:center;padding:20px;background:#F0F4FF;border-radius:8px;margin:20px 0;'>
                                {$this->otp}
                            </div>
                            <p style='color:#78909C;font-size:13px;'>Kode berlaku selama <b>5 menit</b>. Jangan bagikan kode ini kepada siapapun.</p>
                        </div>
                    ");
    }
}