<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kendaraan', function (Blueprint $table) {
            $table->enum('jenis_pembayaran', ['cash', 'credit'])->nullable()->after('kepemilikan');
            $table->enum('jenis_kredit', ['leasing', 'bank'])->nullable()->after('jenis_pembayaran');
            $table->unsignedSmallInteger('tenor')->nullable()->after('jenis_kredit'); // bulan
            $table->string('file_kontrak')->nullable()->after('tenor');
        });
    }

    public function down(): void
    {
        Schema::table('kendaraan', function (Blueprint $table) {
            $table->dropColumn(['jenis_pembayaran', 'jenis_kredit', 'tenor', 'file_kontrak']);
        });
    }
};
