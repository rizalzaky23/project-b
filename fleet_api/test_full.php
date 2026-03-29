<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::create('/api/servis-kendaraan', 'POST', [
    'kendaraan_id' => 1,
    'tanggal_servis' => '2026-03-28'
], [], [], [
    'HTTP_ACCEPT' => 'application/json'
]);

// Auth bypass
$user = \App\Models\User::first() ?? \App\Models\User::factory()->create();
$app->make('auth')->setDefaultDriver('sanctum');
\Laravel\Sanctum\Sanctum::actingAs($user, ['*']);

$response = $kernel->handle($request);

echo $response->getStatusCode() . "\n";
echo $response->getContent() . "\n";
