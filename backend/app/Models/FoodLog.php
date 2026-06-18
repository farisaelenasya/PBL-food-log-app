<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FoodLog extends Model
{
    protected $table = 'food_logs';

    protected $fillable = [
        'nama_makanan',
        'gram',
        'waktu_makan',
        'kalori',
        'karbo',
        'protein',
        'lemak',
        'serat',
        'gula',
        'indeks_glikemik',
        'foto_path',
        'dicatat_pada',
    ];
}