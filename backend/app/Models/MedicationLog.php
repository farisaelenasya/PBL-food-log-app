<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MedicationLog extends Model
{
    protected $fillable = [
        'user_id',
        'medication_id',
        'status',
        'waktu_aksi',
        'tunda_sampai',
    ];

    protected $casts = [
        'waktu_aksi' => 'datetime',
        'tunda_sampai' => 'datetime',
    ];

    public function medication()
    {
        return $this->belongsTo(Medication::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}