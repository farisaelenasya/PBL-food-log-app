<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Glucose extends Model
{
    protected $fillable = [
        'user_id',
        'patient_name',
        'glucose_level',
        'konteks_makan',
        'catatan',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}