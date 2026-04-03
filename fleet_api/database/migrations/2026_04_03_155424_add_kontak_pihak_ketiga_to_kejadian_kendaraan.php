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
        Schema::table('kejadian_kendaraan', function (Blueprint $table) {
            $table->string('kontak_pihak_ketiga')->nullable()->after('jenis_kejadian');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kejadian_kendaraan', function (Blueprint $table) {
            $table->dropColumn('kontak_pihak_ketiga');
        });
    }
};
