<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DetailKendaraan extends Model
{
    use HasFactory;

    protected $table = 'detail_kendaraan';

    protected $fillable = [
        'kendaraan_id',
        'no_polisi',
        'pemilik_komersial',
        'pemilik_viskal',
        'foto_stnk',
        'stnk_berlaku_mulai',
        'stnk_berlaku_akhir',
        'foto_bpkb',
        'foto_nomor',
        'foto_km',
        'kartu_kir',
        'lembar_kir',
    ];

    protected $casts = [
        'stnk_berlaku_mulai' => 'date',
        'stnk_berlaku_akhir' => 'date',
    ];

    public function kendaraan()
    {
        return $this->belongsTo(Kendaraan::class, 'kendaraan_id');
    }
}
