<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Penyewaan\StorePenyewaanRequest;
use App\Http\Requests\Penyewaan\UpdatePenyewaanRequest;
use App\Models\Penyewaan;
use App\Services\PhotoUploadService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class PenyewaanController extends Controller
{
    use ApiResponse;

    public function __construct(private PhotoUploadService $photoService) {}

    public function index(Request $request)
    {
        $query = Penyewaan::with('kendaraan.detail')
            ->when($request->kendaraan_id, fn($q, $v) => $q->where('kendaraan_id', $v))
            ->when($request->nama_penyewa, fn($q, $v) => $q->where('nama_penyewa', 'like', "%{$v}%"))
            ->when($request->group !== null, fn($q) => $q->where('group', filter_var($request->group, FILTER_VALIDATE_BOOLEAN)))
            ->when($request->aktif, function ($q) {
                $today = now()->toDateString();
                $q->whereDate('tanggal_mulai', '<=', $today)
                  ->whereDate('tanggal_selesai', '>=', $today);
            })
            ->when($request->tanggal_dari, fn($q, $v) => $q->whereDate('tanggal_mulai', '>=', $v))
            ->when($request->tanggal_sampai, fn($q, $v) => $q->whereDate('tanggal_selesai', '<=', $v))
            ->when($request->search, fn($q, $s) =>
                $q->where('nama_penyewa', 'like', "%{$s}%")
                  ->orWhere('penanggung_jawab', 'like', "%{$s}%")
                  ->orWhere('lokasi_sewa', 'like', "%{$s}%")
            )
            ->latest();

        return $this->paginatedResponse($query->paginate($request->per_page ?? 15));
    }

    public function store(StorePenyewaanRequest $request)
    {
        $data = $request->validated();
        
        if ($request->hasFile('surat_perjanjian')) {
            $data['surat_perjanjian'] = $this->photoService->upload($request->file('surat_perjanjian'), 'penyewaan');
        }

        $penyewaan = Penyewaan::create($data);
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
        $data = $request->validated();

        if ($request->hasFile('surat_perjanjian')) {
            $this->photoService->delete($penyewaan->surat_perjanjian);
            $data['surat_perjanjian'] = $this->photoService->upload($request->file('surat_perjanjian'), 'penyewaan');
        } elseif ($request->input('delete_surat_perjanjian') == '1' || $request->input('delete_surat_perjanjian') === true) {
            $this->photoService->delete($penyewaan->surat_perjanjian);
            $data['surat_perjanjian'] = null;
        }

        $penyewaan->update($data);
        return $this->successResponse($penyewaan, 'Data penyewaan berhasil diperbarui.');
    }

    public function destroy(Penyewaan $penyewaan)
    {
        if ($penyewaan->surat_perjanjian) {
            $this->photoService->delete($penyewaan->surat_perjanjian);
        }
        $penyewaan->delete();
        return $this->successResponse(null, 'Data penyewaan berhasil dihapus.');
    }
}
