<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        // Cek apakah super admin sudah ada
        if (User::where('role', 'super_admin')->exists()) {
            $this->command->info('Super Admin sudah ada, skip seeding.');
            return;
        }

        User::create([
            'name'     => 'Super Admin',
            'email'    => 'superadmin@fleet.com',
            'password' => Hash::make('password123'),
            'role'     => 'super_admin',
        ]);

        $this->command->info('Super Admin berhasil dibuat: superadmin@fleet.com / password123');
    }
}
