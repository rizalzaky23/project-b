<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Kendaraan\StoreKendaraanRequest;
use App\Http\Requests\Kendaraan\UpdateKendaraanRequest;
use App\Models\Kendaraan;
use App\Services\PhotoUploadService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class KendaraanController extends Controller
{
    use ApiResponse;

    private array $photoFields = ['foto_depan', 'foto_kiri', 'foto_kanan', 'foto_belakang'];

    public function __construct(private PhotoUploadService $photoService) {}

    public function index(Request $request)
    {
        $query = Kendaraan::with('detail')
            ->withExists(['penyewaan as is_rented' => function($q) {
                $today = now()->toDateString();
                $q->whereDate('tanggal_mulai', '<=', $today)
                  ->whereDate('tanggal_selesai', '>=', $today);
            }])
            ->when($request->search, fn($q, $s) =>
                $q->where('kode_kendaraan', 'like', "%{$s}%")
                  ->orWhere('merk', 'like', "%{$s}%")
                  ->orWhere('tipe', 'like', "%{$s}%")
            )
            ->when($request->merk, fn($q, $v) => $q->where('merk', $v))
            ->when($request->warna, fn($q, $v) => $q->where('warna', $v))
            ->when($request->tahun_pembuatan, fn($q, $v) => $q->where('tahun_pembuatan', $v))
            ->when($request->kepemilikan, fn($q, $v) => $q->where('kepemilikan', $v))
            ->when($request->status, fn($q, $v) => $q->where('status', $v))
            ->latest();

        $paginated = $query->paginate($request->per_page ?? 15);
        $paginated->getCollection()->transform(function($kendaraan) {
            $kendaraan->is_rented = (bool)$kendaraan->is_rented;
            return $kendaraan;
        });

        return $this->paginatedResponse($paginated);
    }

    public function store(StoreKendaraanRequest $request)
    {
        $data = $request->validated();

        // Upload foto
        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                $data[$field] = $this->photoService->upload($request->file($field), 'kendaraan');
            }
        }

        // Upload PDF kontrak
        if ($request->hasFile('file_kontrak')) {
            $data['file_kontrak'] = $this->photoService->upload($request->file('file_kontrak'), 'kontrak');
        }

        $kendaraan = Kendaraan::create($data);

        return $this->createdResponse($kendaraan, 'Kendaraan berhasil ditambahkan.');
    }

    public function show(Kendaraan $kendaraan)
    {
        $kendaraan->load(['detail', 'asuransi', 'kejadian', 'penyewaan']);
        
        $today = now()->toDateString();
        $kendaraan->is_rented = (bool)$kendaraan->penyewaan()
            ->whereDate('tanggal_mulai', '<=', $today)
            ->whereDate('tanggal_selesai', '>=', $today)
            ->exists();

        return $this->successResponse($kendaraan);
    }

    public function update(UpdateKendaraanRequest $request, Kendaraan $kendaraan)
    {
        $data = $request->validated();

        // Upload / hapus foto
        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                $this->photoService->delete($kendaraan->$field);
                $data[$field] = $this->photoService->upload($request->file($field), 'kendaraan');
            } elseif ($request->input('delete_' . $field) == '1' || $request->input('delete_' . $field) === true) {
                $this->photoService->delete($kendaraan->$field);
                $data[$field] = null;
            }
        }

        // Upload / hapus PDF kontrak
        if ($request->hasFile('file_kontrak')) {
            $this->photoService->delete($kendaraan->file_kontrak);
            $data['file_kontrak'] = $this->photoService->upload($request->file('file_kontrak'), 'kontrak');
        } elseif ($request->input('delete_file_kontrak') == '1') {
            $this->photoService->delete($kendaraan->file_kontrak);
            $data['file_kontrak'] = null;
        }

        $kendaraan->update($data);

        return $this->successResponse($kendaraan, 'Kendaraan berhasil diperbarui.');
    }

    public function destroy(Kendaraan $kendaraan)
    {
        $this->photoService->deleteMany(array_filter(
            array_map(fn($f) => $kendaraan->$f, $this->photoFields)
        ));
        $this->photoService->delete($kendaraan->file_kontrak);

        $kendaraan->delete();

        return $this->successResponse(null, 'Kendaraan berhasil dihapus.');
    }
}
