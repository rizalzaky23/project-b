<?php

namespace App\Http\Requests\KejadianKendaraan;

use Illuminate\Foundation\Http\FormRequest;

class UpdateKejadianKendaraanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'tanggal'   => 'sometimes|date',
            'foto_km'   => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_1'    => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_2'    => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'deskripsi' => 'nullable|string',
        ];
    }
}
