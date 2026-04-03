<?php

namespace App\Http\Requests\DetailKendaraan;

use Illuminate\Foundation\Http\FormRequest;

class UpdateDetailKendaraanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'no_polisi'           => 'sometimes|string|max:20',
            'pemilik_komersial'   => 'sometimes|string|max:200',
            'pemilik_viskal'      => 'nullable|string|max:200',
            'foto_stnk'           => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'stnk_berlaku_mulai'  => 'nullable|date',
            'stnk_berlaku_akhir'  => 'nullable|date',
            'foto_bpkb'           => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_nomor'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_km'             => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'kartu_kir'           => 'nullable|file|mimes:pdf|max:10240',
            'lembar_kir'          => 'nullable|file|mimes:pdf|max:10240',
            'kir_berlaku_mulai'   => 'nullable|date',
            'kir_berlaku_akhir'   => 'nullable|date',
            'delete_foto_stnk'    => 'nullable|in:0,1',
            'delete_foto_bpkb'    => 'nullable|in:0,1',
            'delete_foto_nomor'   => 'nullable|in:0,1',
            'delete_foto_km'      => 'nullable|in:0,1',
            'delete_kartu_kir'    => 'nullable|in:0,1',
            'delete_lembar_kir'   => 'nullable|in:0,1',
        ];
    }
}
