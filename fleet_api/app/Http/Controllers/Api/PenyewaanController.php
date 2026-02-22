<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Penyewaan\StorePenyewaanRequest;
use App\Http\Requests\Penyewaan\UpdatePenyewaanRequest;
use App\Models\Penyewaan;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class PenyewaanController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Penyewaan::with('kendaraan.detail')
            ->when($request->kendaraan_id, fn($q, $v) => $q->where('kendaraan_id', $v))
            ->when($request->kode_penyewa, fn($q, $v) => $q->where('kode_penyewa', 'like', "%{$v}%"))
            ->when($request->group !== null, fn($q) => $q->where('group', filter_var($request->group, FILTER_VALIDATE_BOOLEAN)))
            ->when($request->aktif, function ($q) {
                $today = now()->toDateString();
                $q->where('tanggal_mulai', '<=', $today)
                  ->where('tanggal_selesai', '>=', $today);
            })
            ->when($request->tanggal_dari, fn($q, $v) => $q->whereDate('tanggal_mulai', '>=', $v))
            ->when($request->tanggal_sampai, fn($q, $v) => $q->whereDate('tanggal_selesai', '<=', $v))
            ->when($request->search, fn($q, $s) =>
                $q->where('kode_penyewa', 'like', "%{$s}%")
                  ->orWhere('penanggung_jawab', 'like', "%{$s}%")
                  ->orWhere('lokasi_sewa', 'like', "%{$s}%")
            )
            ->latest();

        return $this->paginatedResponse($query->paginate($request->per_page ?? 15));
    }

    public function store(StorePenyewaanRequest $request)
    {
        $penyewaan = Penyewaan::create($request->validated());
        $penyewaan->load('kendaraan.detail');

        return $this->createdResponse($penyewaan, 'Data penyewaan berhasil ditambahkan.');
    }

    public function show(Penyewaan $penyewaan)
    {
        $penyewaan->load('kendaraan.detail');
        return $this->successResponse($penyewaan);
    }

    public function update(UpdatePenyewaanRequest $request, Penyewaan $penyewaan)
    {
        $penyewaan->update($request->validated());
        return $this->successResponse($penyewaan, 'Data penyewaan berhasil diperbarui.');
    }

    public function destroy(Penyewaan $penyewaan)
    {
        $penyewaan->delete();
        return $this->successResponse(null, 'Data penyewaan berhasil dihapus.');
    }
}
