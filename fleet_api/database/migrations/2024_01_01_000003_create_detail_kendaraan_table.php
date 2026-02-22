<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('detail_kendaraan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kendaraan_id')
                  ->constrained('kendaraan')
                  ->onDelete('cascade');
            $table->string('no_polisi', 20);
            $table->date('berlaku_mulai')->nullable();
            $table->string('nama_pemilik', 200);
            $table->string('foto_stnk')->nullable();
            $table->string('foto_bpkb')->nullable();
            $table->string('foto_nomor')->nullable();
            $table->string('foto_km')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('detail_kendaraan');
    }
};
