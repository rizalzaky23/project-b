<?php

namespace App\Http\Requests\Penyewaan;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePenyewaanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'nama_penyewa'           => 'sometimes|string|max:50',
            'group'                  => 'sometimes|boolean',
            'masa_sewa'              => 'sometimes|integer|min:1',
            'tanggal_mulai'          => 'sometimes|date',
            'tanggal_selesai'        => 'sometimes|date|after_or_equal:tanggal_mulai',
            'penanggung_jawab'       => 'sometimes|string|max:200',
            'lokasi_sewa'            => 'nullable|string|max:300',
            'nilai_sewa'             => 'sometimes|numeric|min:0',
            'surat_perjanjian'       => 'nullable|file|mimes:pdf|max:10240',
            'delete_surat_perjanjian'=> 'nullable|in:0,1',
        ];
    }
}
