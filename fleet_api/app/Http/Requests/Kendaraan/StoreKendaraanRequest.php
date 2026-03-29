<?php

namespace App\Http\Requests\Kendaraan;

use Illuminate\Foundation\Http\FormRequest;

class StoreKendaraanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'kode_kendaraan'  => 'required|string|max:50|unique:kendaraan,kode_kendaraan',
            'merk'            => 'required|string|max:100',
            'tipe'            => 'required|string|max:100',
            'warna'           => 'required|string|max:50',
            'no_chasis'       => 'required|string|max:100|unique:kendaraan,no_chasis',
            'no_mesin'        => 'required|string|max:100|unique:kendaraan,no_mesin',
            'tahun_perolehan' => 'required|integer|digits:4',
            'tahun_pembuatan' => 'required|integer|digits:4',
            'harga_perolehan' => 'required|numeric|min:0',
            'dealer'          => 'nullable|string|max:200',
            'kepemilikan'    => 'nullable|in:PT1,PT2,PT3',
            'jenis_pembayaran' => 'nullable|in:cash,credit',
            'jenis_kredit'     => 'nullable|in:leasing,bank|required_if:jenis_pembayaran,credit',
            'tenor'            => 'nullable|integer|min:1|max:360|required_if:jenis_kredit,bank',
            'file_kontrak'     => 'nullable|file|mimes:pdf|max:10240',
            'foto_depan'      => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_kiri'       => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_kanan'      => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'foto_belakang'   => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
        ];
    }
}
