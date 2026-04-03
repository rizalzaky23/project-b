<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('detail_kendaraan', function (Blueprint $table) {
            $table->dropColumn('masa_berlaku_kir');
            $table->date('kir_berlaku_mulai')->nullable()->after('lembar_kir');
            $table->date('kir_berlaku_akhir')->nullable()->after('kir_berlaku_mulai');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('detail_kendaraan', function (Blueprint $table) {
            $table->dropColumn(['kir_berlaku_mulai', 'kir_berlaku_akhir']);
            $table->date('masa_berlaku_kir')->nullable()->after('lembar_kir');
        });
    }
};
