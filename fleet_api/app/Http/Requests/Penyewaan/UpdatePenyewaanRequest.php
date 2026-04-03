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

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            $penyewaan = $this->route('penyewaan');
            if (!$penyewaan) return;
            
            // If route model binding is working, $penyewaan is a model. If not, it's an ID.
            $id = $penyewaan instanceof \App\Models\Penyewaan ? $penyewaan->id : $penyewaan;
            $kendaraanId = $penyewaan instanceof \App\Models\Penyewaan ? $penyewaan->kendaraan_id : \App\Models\Penyewaan::where('id', $id)->value('kendaraan_id');

            $mulai = $this->input('tanggal_mulai') ?? ($penyewaan instanceof \App\Models\Penyewaan ? \Carbon\Carbon::parse($penyewaan->tanggal_mulai)->toDateString() : \App\Models\Penyewaan::where('id', $id)->value('tanggal_mulai'));
            $selesai = $this->input('tanggal_selesai') ?? ($penyewaan instanceof \App\Models\Penyewaan ? \Carbon\Carbon::parse($penyewaan->tanggal_selesai)->toDateString() : \App\Models\Penyewaan::where('id', $id)->value('tanggal_selesai'));

            if ($kendaraanId && $mulai && $selesai) {
                $exists = \App\Models\Penyewaan::where('kendaraan_id', $kendaraanId)
                    ->where('id', '!=', $id)
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
