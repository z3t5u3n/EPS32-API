<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Dth11 extends Model
{
    use HasFactory;

    // Nombre de la tabla de la base de datos
    protected $table = 'humedad';

    // Campos que pueden ser llenados masivamente
    // Hemos renombrado 'humedad' a 'humedad_ambiente' para mayor claridad
    // y añadido 'porcentaje_llenado' para el sensor YL69.
    protected $fillable = [
        'humedad_ambiente',
        'temperatura',
        'porcentaje_llenado' // Nuevo campo para el sensor YL69/HL69
    ];

    // Desactiva los timestamps si la tabla no tiene 'created_at' y 'updated_at'
    public $timestamps = false;
}