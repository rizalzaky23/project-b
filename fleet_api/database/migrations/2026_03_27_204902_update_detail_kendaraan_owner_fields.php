<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('detail_kendaraan', function (Blueprint $table) {
            // Hapus berlaku_mulai
            $table->dropColumn('berlaku_mulai');

            // Rename nama_pemilik -> pemilik_komersial, tambah pemilik_viskal
            $table->renameColumn('nama_pemilik', 'pemilik_komersial');
            $table->string('pemilik_viskal', 200)->nullable()->after('pemilik_komersial');
        });
    }

    public function down(): void
    {
        Schema::table('detail_kendaraan', function (Blueprint $table) {
            $table->date('berlaku_mulai')->nullable()->after('no_polisi');
            $table->renameColumn('pemilik_komersial', 'nama_pemilik');
            $table->dropColumn('pemilik_viskal');
        });
    }
};
