<?php

namespace App\Http\Requests\AsuransiKendaraan;

use Illuminate\Foundation\Http\FormRequest;

class UpdateAsuransiKendaraanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        $id = $this->route('asuransi');

        return [
            'perusahaan_asuransi' => 'sometimes|string|max:200',
            'jenis_asuransi'      => 'sometimes|string|max:100',
            'tanggal_mulai'       => 'sometimes|date',
            'tanggal_akhir'       => 'sometimes|date|after:tanggal_mulai',
            'no_polis'            => "sometimes|string|max:100|unique:asuransi_kendaraan,no_polis,{$id}",
            'nilai_premi'         => 'sometimes|numeric|min:0',
            'nilai_pertanggungan' => 'sometimes|numeric|min:0',
            'foto_depan'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_kiri'           => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_kanan'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_belakang'       => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_dashboard'      => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_km'             => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
        ];
    }
}
