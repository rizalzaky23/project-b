<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('penyewaan', function (Blueprint $table) {
            // Rename kode_penyewa -> nama_penyewa
            $table->renameColumn('kode_penyewa', 'nama_penyewa');

            // Hapus kolom sales
            $table->dropColumn('sales');

            // Tambah surat_perjanjian (path file PDF)
            $table->string('surat_perjanjian')->nullable()->after('lokasi_sewa');
        });
    }

    public function down(): void
    {
        Schema::table('penyewaan', function (Blueprint $table) {
            $table->renameColumn('nama_penyewa', 'kode_penyewa');
            $table->string('sales', 200)->nullable();
            $table->dropColumn('surat_perjanjian');
        });
    }
};
