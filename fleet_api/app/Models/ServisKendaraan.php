<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServisKendaraan extends Model
{
    use HasFactory;

    protected $table = 'servis_kendaraan';

    protected $fillable = [
        'kendaraan_id',
        'tanggal_servis',
        'kilometer',
        'foto_km',
        'foto_invoice',
    ];

    public function kendaraan()
    {
        return $this->belongsTo(Kendaraan::class, 'kendaraan_id');
    }
}
