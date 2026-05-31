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
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}