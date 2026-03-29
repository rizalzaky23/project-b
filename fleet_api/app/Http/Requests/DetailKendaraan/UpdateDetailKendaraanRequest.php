<?php

namespace App\Http\Requests\DetailKendaraan;

use Illuminate\Foundation\Http\FormRequest;

class UpdateDetailKendaraanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'no_polisi'          => 'sometimes|string|max:20',
            'berlaku_mulai'      => 'nullable|date',
            'nama_pemilik'       => 'sometimes|string|max:200',
            'foto_stnk'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_bpkb'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_nomor'         => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_km'            => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'delete_foto_stnk'   => 'nullable|in:0,1',
            'delete_foto_bpkb'   => 'nullable|in:0,1',
            'delete_foto_nomor'  => 'nullable|in:0,1',
            'delete_foto_km'     => 'nullable|in:0,1',
        ];
    }
}
