<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('humedad', function (Blueprint $table) {
            
            // 1. Renombrar la columna 'humedad' (antigua) a 'humedad_ambiente' (nueva)
            // Esto soluciona el error "Unknown column 'humedad_ambiente'"
            $table->renameColumn('humedad', 'humedad_ambiente'); 
            
            // 2. Agregar la columna 'porcentaje_llenado'
            // Asegúrate de que el tipo sea FLOAT o DECIMAL, no VARCHAR.
            $table->float('porcentaje_llenado')->nullable()->after('humedad_ambiente');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('humedad', function (Blueprint $table) {
            // Revertir el cambio de nombre
            $table->renameColumn('humedad_ambiente', 'humedad');
            
            // Eliminar la columna
            $table->dropColumn('porcentaje_llenado');
        });
    }
};