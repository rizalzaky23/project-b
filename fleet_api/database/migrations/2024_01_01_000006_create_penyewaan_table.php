<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('penyewaan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kendaraan_id')
                  ->constrained('kendaraan')
                  ->onDelete('cascade');
            $table->string('kode_penyewa', 50);
            $table->boolean('group')->default(false); // true = group, false = non-group
            $table->unsignedInteger('masa_sewa'); // in days
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai');
            $table->string('penanggung_jawab', 200);
            $table->string('lokasi_sewa', 300)->nullable();
            $table->string('sales', 200)->nullable();
            $table->decimal('nilai_sewa', 15, 2)->default(0);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('penyewaan');
    }
};
