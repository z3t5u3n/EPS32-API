<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\Dth11; 

// ===============================================
// 1. RUTA POST: ALMACENAMIENTO DE DATOS (PARA EL ESP32)
// Recibe los tres valores y los guarda en la base de datos.
// URL: POST /api/humedad
// ===============================================
Route::post('/humedad', function (Request $request) {
    
    try {
        // 1. Validación de los tres campos
        $validatedData = $request->validate([
            'temperatura_ambiente' => 'required|numeric',
            'humedad_ambiente' => 'required|numeric',
            'porcentaje_llenado' => 'required|numeric', 
        ]);

        // 2. Guardar el registro en la base de datos
        $datos = new Dth11();
        
        // Mapeo de request keys (enviadas por el ESP32) a model keys (en la DB)
        $datos->temperatura = $validatedData['temperatura_ambiente'];
        $datos->humedad_ambiente = $validatedData['humedad_ambiente'];
        $datos->porcentaje_llenado = $validatedData['porcentaje_llenado'];
        
        $datos->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Datos guardados correctamente'
        ], 201); 
    
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Error al guardar datos. Revise el request y la DB: ' . $e->getMessage()
        ], 400);
    }
});

// ===============================================
// 2. RUTA GET: DATOS DHT11 (TEMPERATURA Y HUMEDAD AMBIENTE)
// URL: GET /api/dht
// ===============================================
Route::get('/dht', function () {
    // Seleccionamos solo los campos de DHT11: temperatura y humedad_ambiente
    $latestData = Dth11::latest('fecha')->first(['temperatura', 'humedad_ambiente']);
    
    if (!$latestData) {
        return response()->json(['message' => 'No hay datos de DHT11 disponibles.'], 404);
    }
    
    return response()->json($latestData);
});

// ===============================================
// 3. RUTA GET: DATOS YL69 (PORCENTAJE DE LLENADO)
// URL: GET /api/yl69
// ===============================================
Route::get('/yl69', function () {
    // Seleccionamos solo el campo del YL69: porcentaje_llenado
    $latestData = Dth11::latest('fecha')->first(['porcentaje_llenado']);
    
    if (!$latestData) {
        return response()->json(['message' => 'No hay datos de YL69 disponibles.'], 404);
    }
    
    return response()->json($latestData);
});

// ===============================================
// 4. RUTA GET: TODOS LOS DATOS COMBINADOS (USO PRINCIPAL EN REACT)
// URL: GET /api/data
// ===============================================
Route::get('/data', function () {
    // latest() sin argumentos específicos trae todos los campos del último registro
    $ultimoDato = Dth11::latest('fecha')->first();
    
    if (!$ultimoDato) {
        return response()->json(['message' => 'No hay datos disponibles.'], 404);
    }
    
    // El frontend de React usará este JSON para actualizar todos los indicadores.
    return response()->json($ultimoDato);
});