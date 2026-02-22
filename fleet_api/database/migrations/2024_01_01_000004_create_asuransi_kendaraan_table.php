<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('asuransi_kendaraan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kendaraan_id')
                  ->constrained('kendaraan')
                  ->onDelete('cascade');
            $table->string('perusahaan_asuransi', 200);
            $table->string('jenis_asuransi', 100); // all-risk | TLO
            $table->date('tanggal_mulai');
            $table->date('tanggal_akhir');
            $table->string('no_polis', 100)->unique();
            $table->decimal('nilai_premi', 15, 2)->default(0);
            $table->decimal('nilai_pertanggungan', 15, 2)->default(0);
            $table->string('foto_depan')->nullable();
            $table->string('foto_kiri')->nullable();
            $table->string('foto_kanan')->nullable();
            $table->string('foto_belakang')->nullable();
            $table->string('foto_dashboard')->nullable();
            $table->string('foto_km')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('asuransi_kendaraan');
    }
};
