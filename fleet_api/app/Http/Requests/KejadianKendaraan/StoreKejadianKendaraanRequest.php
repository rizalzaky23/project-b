<?php

namespace App\Http\Requests\KejadianKendaraan;

use Illuminate\Foundation\Http\FormRequest;

class StoreKejadianKendaraanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'kendaraan_id' => 'required|exists:kendaraan,id',
            'tanggal'        => 'required|date',
            'jenis_kejadian' => 'nullable|string|max:100',
            'lokasi'         => 'nullable|string|max:255',
            'status'         => 'nullable|string|in:progres,selesai',
            'foto_km'        => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_1'       => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_2'       => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'deskripsi'    => 'nullable|string',
        ];
    }
}
