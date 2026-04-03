<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KejadianKendaraan extends Model
{
    use HasFactory;

    protected $table = 'kejadian_kendaraan';

    protected $fillable = [
        'kendaraan_id',
        'tanggal',
        'jenis_kejadian',
        'kontak_pihak_ketiga',
        'lokasi',
        'status',
        'foto_km',
        'foto_1',
        'foto_2',
        'deskripsi',
    ];

    protected $casts = [
        'tanggal' => 'date',
    ];

    public function kendaraan()
    {
        return $this->belongsTo(Kendaraan::class, 'kendaraan_id');
    }
}
