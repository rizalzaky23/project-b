<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AsuransiKendaraan\StoreAsuransiKendaraanRequest;
use App\Http\Requests\AsuransiKendaraan\UpdateAsuransiKendaraanRequest;
use App\Models\AsuransiKendaraan;
use App\Services\PhotoUploadService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AsuransiKendaraanController extends Controller
{
    use ApiResponse;

    private array $photoFields = [
        'foto_depan', 'foto_kiri', 'foto_kanan',
        'foto_belakang', 'foto_dashboard', 'foto_km',
    ];

    public function __construct(private PhotoUploadService $photoService) {}

    public function index(Request $request)
    {
        $query = AsuransiKendaraan::with('kendaraan')
            ->when($request->kendaraan_id, fn($q, $v) => $q->where('kendaraan_id', $v))
            ->when($request->jenis_asuransi, fn($q, $v) => $q->where('jenis_asuransi', $v))
            ->when($request->aktif, function ($q) {
                $q->where('tanggal_akhir', '>=', now()->toDateString());
            })
            ->when($request->search, fn($q, $s) =>
                $q->where('no_polis', 'like', "%{$s}%")
                  ->orWhere('perusahaan_asuransi', 'like', "%{$s}%")
            )
            ->latest();

        return $this->paginatedResponse($query->paginate($request->per_page ?? 15));
    }

    public function store(StoreAsuransiKendaraanRequest $request)
    {
        $data = $request->validated();

        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                $data[$field] = $this->photoService->upload($request->file($field), 'asuransi');
            }
        }

        $asuransi = AsuransiKendaraan::create($data);
        $asuransi->load('kendaraan');

        return $this->createdResponse($asuransi, 'Data asuransi berhasil ditambahkan.');
    }

    public function show(AsuransiKendaraan $asuransi)
    {
        $asuransi->load('kendaraan');
        return $this->successResponse($asuransi);
    }

    public function update(UpdateAsuransiKendaraanRequest $request, AsuransiKendaraan $asuransi)
    {
        $data = $request->validated();

        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                $this->photoService->delete($asuransi->$field);
                $data[$field] = $this->photoService->upload($request->file($field), 'asuransi');
            }
        }

        $asuransi->update($data);

        return $this->successResponse($asuransi, 'Data asuransi berhasil diperbarui.');
    }

    public function destroy(AsuransiKendaraan $asuransi)
    {
        $this->photoService->deleteMany(array_filter(
            array_map(fn($f) => $asuransi->$f, $this->photoFields)
        ));

        $asuransi->delete();

        return $this->successResponse(null, 'Data asuransi berhasil dihapus.');
    }
}
