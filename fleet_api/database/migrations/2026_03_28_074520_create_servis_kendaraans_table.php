<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('servis_kendaraan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kendaraan_id')->constrained('kendaraan')->onDelete('cascade');
            $table->date('tanggal_servis')->nullable();
            $table->integer('kilometer')->default(0);
            $table->string('foto_km')->nullable();
            $table->string('foto_invoice')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('servis_kendaraan');
    }
};
