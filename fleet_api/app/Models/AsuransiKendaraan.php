<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AsuransiKendaraan extends Model
{
    use HasFactory;

    protected $table = 'asuransi_kendaraan';

    protected $fillable = [
        'kendaraan_id',
        'perusahaan_asuransi',
        'jenis_asuransi',
        'tanggal_mulai',
        'tanggal_akhir',
        'no_polis',
        'nilai_premi',
        'nilai_pertanggungan',
        'foto_depan',
        'foto_kiri',
        'foto_kanan',
        'foto_belakang',
        'foto_dashboard',
        'foto_km',
    ];

    protected $casts = [
        'tanggal_mulai'       => 'date',
        'tanggal_akhir'       => 'date',
        'nilai_premi'         => 'decimal:2',
        'nilai_pertanggungan' => 'decimal:2',
    ];

    public function kendaraan()
    {
        return $this->belongsTo(Kendaraan::class, 'kendaraan_id');
    }
}
