<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AsuransiKendaraanController;
use App\Http\Controllers\Api\DetailKendaraanController;
use App\Http\Controllers\Api\KejadianKendaraanController;
use App\Http\Controllers\Api\KendaraanController;
use App\Http\Controllers\Api\PenyewaanController;
use App\Http\Controllers\Api\ServisKendaraanController;
use App\Http\Controllers\Api\UserController;
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

    // ─── API Resources (CRUD Restricted to Admin, Read to All) ────
    Route::middleware('role.admin')->group(function () {
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

        // Servis Kendaraan
        Route::apiResource('servis-kendaraan', ServisKendaraanController::class)
            ->parameters(['servis-kendaraan' => 'servis']);

        // Merek (Read-only for admin)
        Route::apiResource('mereks', \App\Http\Controllers\Api\MerekController::class)->only(['index', 'show']);
    });

    // ─── User Management (Super Admin Only) ───────────────────────
    Route::middleware('role.super_admin')->group(function () {
        Route::apiResource('users', UserController::class)->except(['show']);
        
        // Merek (Write-access for super admin)
        Route::apiResource('mereks', \App\Http\Controllers\Api\MerekController::class)->except(['index', 'show']);
    });
});
