<?php

namespace App\Http\Requests\Kendaraan;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateKendaraanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        $kendaraan = $this->route('kendaraan');
        $id = is_object($kendaraan) ? $kendaraan->getKey() : $kendaraan;

        return [
            'kode_kendaraan'  => ['sometimes', 'string', 'max:50',  Rule::unique('kendaraan', 'kode_kendaraan')->ignore($id)],
            'merk'            => ['sometimes', 'string', 'max:100'],
            'tipe'            => ['sometimes', 'string', 'max:100'],
            'warna'           => ['sometimes', 'string', 'max:50'],
            'no_chasis'       => ['sometimes', 'string', 'max:100', Rule::unique('kendaraan', 'no_chasis')->ignore($id)],
            'no_mesin'        => ['sometimes', 'string', 'max:100', Rule::unique('kendaraan', 'no_mesin')->ignore($id)],
            'tahun_perolehan' => ['sometimes', 'integer', 'digits:4'],
            'tahun_pembuatan' => ['sometimes', 'integer', 'digits:4'],
            'harga_perolehan' => ['sometimes', 'numeric', 'min:0'],
            'dealer'          => ['nullable', 'string', 'max:200'],
            'kepemilikan'    => ['nullable', 'in:PT1,PT2,PT3'],
            'jenis_pembayaran' => ['nullable', 'in:cash,credit'],
            'jenis_kredit'     => ['nullable', 'in:leasing,bank'],
            'tenor'            => ['nullable', 'integer', 'min:1', 'max:360'],
            'file_kontrak'     => ['nullable', 'file', 'mimes:pdf', 'max:10240'],
            'foto_depan'      => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'foto_kiri'       => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'foto_kanan'      => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'foto_belakang'   => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'status'          => ['nullable', 'string', 'in:Tersedia,Terjual'],
            'tanggal_jual'    => ['nullable', 'date'],
            'harga_jual'      => ['nullable', 'numeric', 'min:0'],
        ];
    }
}