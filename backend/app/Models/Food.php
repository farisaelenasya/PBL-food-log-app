<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Food extends Model
{
    protected $table = 'foods';

    protected $fillable = [
        'nama',
        'kategori',
        'emoji',
        'kalori_100g',
        'karbo_100g',
        'protein_100g',
        'lemak_100g',
        'serat_100g',
        'gula_100g',
        'indeks_glikemik',
    ];
}