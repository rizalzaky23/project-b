<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kendaraan', function (Blueprint $table) {
            $table->id();
            $table->string('kode_kendaraan', 50)->unique();
            $table->string('merk', 100);
            $table->string('tipe', 100);
            $table->string('warna', 50);
            $table->string('no_chasis', 100)->unique();
            $table->string('no_mesin', 100)->unique();
            $table->year('tahun_perolehan');
            $table->year('tahun_pembuatan');
            $table->decimal('harga_perolehan', 15, 2)->default(0);
            $table->string('dealer', 200)->nullable();
            $table->string('foto_depan')->nullable();
            $table->string('foto_kiri')->nullable();
            $table->string('foto_kanan')->nullable();
            $table->string('foto_belakang')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kendaraan');
    }
};
