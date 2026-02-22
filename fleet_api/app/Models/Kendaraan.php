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
        'foto_depan',
        'foto_kiri',
        'foto_kanan',
        'foto_belakang',
    ];

    protected $casts = [
        'harga_perolehan' => 'decimal:2',
        'tahun_perolehan' => 'integer',
        'tahun_pembuatan' => 'integer',
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
