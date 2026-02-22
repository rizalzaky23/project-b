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
        'berlaku_mulai',
        'nama_pemilik',
        'foto_stnk',
        'foto_bpkb',
        'foto_nomor',
        'foto_km',
    ];

    protected $casts = [
        'berlaku_mulai' => 'date',
    ];

    public function kendaraan()
    {
        return $this->belongsTo(Kendaraan::class, 'kendaraan_id');
    }
}
