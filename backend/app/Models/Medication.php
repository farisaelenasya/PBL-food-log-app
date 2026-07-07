<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medication extends Model
{
    protected $fillable = [
        'user_id',
        'nama_obat',
        'dosis',
        'frekuensi',
        'waktu_konsumsi',
        'tipe',
        'catatan',
        'hari_terpilih',
    ];

    protected $casts = [
        'hari_terpilih' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}