<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AsuransiKendaraanController;
use App\Http\Controllers\Api\DetailKendaraanController;
use App\Http\Controllers\Api\KejadianKendaraanController;
use App\Http\Controllers\Api\KendaraanController;
use App\Http\Controllers\Api\PenyewaanController;
use Illuminate\Support\Facades\Route;

// ─── Public Auth Routes ───────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login',    [AuthController::class, 'login']);
});

// ─── Protected Routes ─────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::prefix('auth')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me',      [AuthController::class, 'me']);
    });

    // Kendaraan
    Route::apiResource('kendaraan', KendaraanController::class);

    // Detail Kendaraan
    Route::apiResource('detail-kendaraan', DetailKendaraanController::class)
        ->parameters(['detail-kendaraan' => 'detailKendaraan']);

    // Asuransi Kendaraan
    Route::apiResource('asuransi-kendaraan', AsuransiKendaraanController::class)
        ->parameters(['asuransi-kendaraan' => 'asuransi']);

    // Kejadian Kendaraan
    Route::apiResource('kejadian-kendaraan', KejadianKendaraanController::class)
        ->parameters(['kejadian-kendaraan' => 'kejadian']);

    // Penyewaan
    Route::apiResource('penyewaan', PenyewaanController::class);
});
