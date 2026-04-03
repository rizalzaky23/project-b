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
            $table->string('jenis_kejadian')->nullable()->after('tanggal');
            $table->string('lokasi')->nullable()->after('jenis_kejadian');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kejadian_kendaraan', function (Blueprint $table) {
            $table->dropColumn(['jenis_kejadian', 'lokasi']);
        });
    }
};
