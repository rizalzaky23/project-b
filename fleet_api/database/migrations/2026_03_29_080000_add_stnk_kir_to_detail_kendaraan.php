<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('detail_kendaraan', function (Blueprint $table) {
            $table->date('stnk_berlaku_mulai')->nullable()->after('foto_stnk');
            $table->date('stnk_berlaku_akhir')->nullable()->after('stnk_berlaku_mulai');
            $table->string('kartu_kir')->nullable()->after('foto_km');
            $table->string('lembar_kir')->nullable()->after('kartu_kir');
        });
    }

    public function down(): void
    {
        Schema::table('detail_kendaraan', function (Blueprint $table) {
            $table->dropColumn(['stnk_berlaku_mulai', 'stnk_berlaku_akhir', 'kartu_kir', 'lembar_kir']);
        });
    }
};
