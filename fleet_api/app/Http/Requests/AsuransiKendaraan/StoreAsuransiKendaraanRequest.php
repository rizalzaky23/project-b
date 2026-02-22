<?php

namespace App\Http\Requests\AsuransiKendaraan;

use Illuminate\Foundation\Http\FormRequest;

class StoreAsuransiKendaraanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'kendaraan_id'        => 'required|exists:kendaraan,id',
            'perusahaan_asuransi' => 'required|string|max:200',
            'jenis_asuransi'      => 'required|string|max:100',
            'tanggal_mulai'       => 'required|date',
            'tanggal_akhir'       => 'required|date|after:tanggal_mulai',
            'no_polis'            => 'required|string|max:100|unique:asuransi_kendaraan,no_polis',
            'nilai_premi'         => 'required|numeric|min:0',
            'nilai_pertanggungan' => 'required|numeric|min:0',
            'foto_depan'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_kiri'           => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_kanan'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_belakang'       => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_dashboard'      => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_km'             => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
        ];
    }
}
