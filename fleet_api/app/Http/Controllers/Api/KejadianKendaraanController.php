<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\KejadianKendaraan\StoreKejadianKendaraanRequest;
use App\Http\Requests\KejadianKendaraan\UpdateKejadianKendaraanRequest;
use App\Models\KejadianKendaraan;
use App\Services\PhotoUploadService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class KejadianKendaraanController extends Controller
{
    use ApiResponse;

    private array $photoFields = ['foto_km', 'foto_1', 'foto_2'];

    public function __construct(private PhotoUploadService $photoService) {}

    public function index(Request $request)
    {
        $query = KejadianKendaraan::with('kendaraan')
            ->when($request->kendaraan_id, fn($q, $v) => $q->where('kendaraan_id', $v))
            ->when($request->tanggal_dari, fn($q, $v) => $q->whereDate('tanggal', '>=', $v))
            ->when($request->tanggal_sampai, fn($q, $v) => $q->whereDate('tanggal', '<=', $v))
            ->when($request->search, fn($q, $s) =>
                $q->where('deskripsi', 'like', "%{$s}%")
            )
            ->orderByDesc('tanggal');

        return $this->paginatedResponse($query->paginate($request->per_page ?? 15));
    }

    public function store(StoreKejadianKendaraanRequest $request)
    {
        $data = $request->validated();

        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                $data[$field] = $this->photoService->upload($request->file($field), 'kejadian');
            }
        }

        $kejadian = KejadianKendaraan::create($data);
        $kejadian->load('kendaraan');

        return $this->createdResponse($kejadian, 'Data kejadian berhasil ditambahkan.');
    }

    public function show(KejadianKendaraan $kejadian)
    {
        $kejadian->load('kendaraan');
        return $this->successResponse($kejadian);
    }

    public function update(UpdateKejadianKendaraanRequest $request, KejadianKendaraan $kejadian)
    {
        $data = $request->validated();

        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                $this->photoService->delete($kejadian->$field);
                $data[$field] = $this->photoService->upload($request->file($field), 'kejadian');
            }
        }

        $kejadian->update($data);

        return $this->successResponse($kejadian, 'Data kejadian berhasil diperbarui.');
    }

    public function destroy(KejadianKendaraan $kejadian)
    {
        $this->photoService->deleteMany(array_filter(
            array_map(fn($f) => $kejadian->$f, $this->photoFields)
        ));

        $kejadian->delete();

        return $this->successResponse(null, 'Data kejadian berhasil dihapus.');
    }
}
