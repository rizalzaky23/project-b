<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Admin
        User::updateOrCreate(
            ['email' => 'admin@fleet.com'],
            [
                'name'     => 'Administrator',
                'password' => Hash::make('password'),
                'role'     => 'admin',
            ]
        );

        // Manager
        User::updateOrCreate(
            ['email' => 'manager@fleet.com'],
            [
                'name'     => 'Fleet Manager',
                'password' => Hash::make('password'),
                'role'     => 'manager',
            ]
        );

        // Staff
        User::updateOrCreate(
            ['email' => 'staff@fleet.com'],
            [
                'name'     => 'Staff Lapangan',
                'password' => Hash::make('password'),
                'role'     => 'staff',
            ]
        );
    }
}
