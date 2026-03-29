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
        Schema::table('kendaraan', function (Blueprint $table) {
            $table->string('status')->default('Tersedia')->after('foto_belakang');
            $table->date('tanggal_jual')->nullable()->after('status');
            $table->decimal('harga_jual', 15, 2)->nullable()->after('tanggal_jual');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kendaraan', function (Blueprint $table) {
            $table->dropColumn(['status', 'tanggal_jual', 'harga_jual']);
        });
    }
};
