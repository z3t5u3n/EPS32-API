<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Dth11 extends Model
{
    use HasFactory;

    // Nombre de la tabla de la base de datos
    protected $table = 'humedad';

    // *** CAMBIO CLAVE ***
    // Indica a Laravel que el campo que debe usar para el ordenamiento cronológico
    // (en lugar del nativo 'created_at') es 'fecha'.
    const CREATED_AT = 'fecha';

    // Campos que pueden ser llenados masivamente
    protected $fillable = [
        'humedad_ambiente',
        'temperatura',
        'porcentaje_llenado'
    ];

    // Desactiva los timestamps si la tabla no tiene 'created_at' y 'updated_at'
    public $timestamps = false;
}