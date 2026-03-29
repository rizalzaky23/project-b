<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::create('/api/servis-kendaraan', 'POST', [], [], [], [
    'HTTP_ACCEPT' => 'application/json'
]);
// Simulate authenticated user (optional, but let's assume auth is working)
$user = new App\Models\User(['id' => 1]);
$app->make('auth')->guard('sanctum')->setUser($user);

$response = $kernel->handle($request);

echo "Status: " . $response->getStatusCode() . "\n";
echo "Content: " . $response->getContent() . "\n";
