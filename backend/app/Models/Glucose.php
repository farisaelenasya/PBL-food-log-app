<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Glucose extends Model
{
    protected $fillable = [
        'patient_name',
        'glucose_level',
    ];
}