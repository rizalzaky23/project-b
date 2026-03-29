<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kendaraan extends Model
{
    use HasFactory;

    protected $table = 'kendaraan';

    protected $fillable = [
        'kode_kendaraan',
        'merk',
        'tipe',
        'warna',
        'no_chasis',
        'no_mesin',
        'tahun_perolehan',
        'tahun_pembuatan',
        'harga_perolehan',
        'dealer',
        'kepemilikan',
        'jenis_pembayaran',
        'jenis_kredit',
        'tenor',
        'file_kontrak',
        'foto_depan',
        'foto_kiri',
        'foto_kanan',
        'foto_belakang',
        'status',
        'tanggal_jual',
        'harga_jual',
    ];

    protected $casts = [
        'harga_perolehan' => 'decimal:2',
        'harga_jual'      => 'decimal:2',
        'tahun_perolehan' => 'integer',
        'tahun_pembuatan' => 'integer',
        'tenor'           => 'integer',
        'tanggal_jual'    => 'date',
    ];

    // ─── Relations ────────────────────────────────────────────

    public function detail()
    {
        return $this->hasOne(DetailKendaraan::class, 'kendaraan_id');
    }

    public function asuransi()
    {
        return $this->hasMany(AsuransiKendaraan::class, 'kendaraan_id');
    }

    public function kejadian()
    {
        return $this->hasMany(KejadianKendaraan::class, 'kendaraan_id');
    }

    public function penyewaan()
    {
        return $this->hasMany(Penyewaan::class, 'kendaraan_id');
    }
}
