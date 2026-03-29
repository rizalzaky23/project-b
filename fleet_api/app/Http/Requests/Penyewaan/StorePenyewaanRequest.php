<?php

namespace App\Http\Requests\Penyewaan;

use Illuminate\Foundation\Http\FormRequest;

class StorePenyewaanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'kendaraan_id'      => 'required|exists:kendaraan,id',
            'nama_penyewa'      => 'required|string|max:50',
            'group'             => 'required|boolean',
            'masa_sewa'         => 'required|integer|min:1',
            'tanggal_mulai'     => 'required|date',
            'tanggal_selesai'   => 'required|date|after_or_equal:tanggal_mulai',
            'penanggung_jawab'  => 'required|string|max:200',
            'lokasi_sewa'       => 'nullable|string|max:300',
            'nilai_sewa'        => 'required|numeric|min:0',
            'surat_perjanjian'  => 'nullable|file|mimes:pdf|max:10240',
        ];
    }
}
