<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Penyewaan extends Model
{
    use HasFactory;

    protected $table = 'penyewaan';

    protected $fillable = [
        'kendaraan_id',
        'kode_penyewa',
        'group',
        'masa_sewa',
        'tanggal_mulai',
        'tanggal_selesai',
        'penanggung_jawab',
        'lokasi_sewa',
        'sales',
        'nilai_sewa',
    ];

    protected $casts = [
        'tanggal_mulai'   => 'date',
        'tanggal_selesai' => 'date',
        'nilai_sewa'      => 'decimal:2',
        'group'           => 'boolean',
    ];

    public function kendaraan()
    {
        return $this->belongsTo(Kendaraan::class, 'kendaraan_id');
    }
}
