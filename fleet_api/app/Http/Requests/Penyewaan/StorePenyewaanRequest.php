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

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            $kendaraanId = $this->input('kendaraan_id');
            $mulai = $this->input('tanggal_mulai');
            $selesai = $this->input('tanggal_selesai');

            if ($kendaraanId && $mulai && $selesai) {
                $exists = \App\Models\Penyewaan::where('kendaraan_id', $kendaraanId)
                    ->where(function ($q) use ($mulai, $selesai) {
                        $q->where('tanggal_mulai', '<=', $selesai)
                          ->where('tanggal_selesai', '>=', $mulai);
                    })
                    ->exists();

                if ($exists) {
                    $validator->errors()->add('tanggal_mulai', 'Mobil masih dalam masa sewa pada periode tersebut.');
                }
            }
        });
    }
}
