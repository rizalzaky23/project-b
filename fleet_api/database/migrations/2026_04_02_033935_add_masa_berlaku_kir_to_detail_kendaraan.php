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
            $table->date('masa_berlaku_kir')->nullable()->after('lembar_kir');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('detail_kendaraan', function (Blueprint $table) {
            $table->dropColumn('masa_berlaku_kir');
        });
    }
};
