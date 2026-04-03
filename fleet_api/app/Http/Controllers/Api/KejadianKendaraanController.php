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

        $paginator = $query->paginate($request->per_page ?? 15);
        $paginator->getCollection()->transform(fn($item) => array_merge($item->toArray(), [
            'status' => $item->status,
            'jenis_kejadian' => $item->jenis_kejadian,
            'lokasi' => $item->lokasi,
        ]));

        return $this->paginatedResponse($paginator);
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
        return $this->successResponse(array_merge($kejadian->toArray(), [
            'status' => $kejadian->status,
            'jenis_kejadian' => $kejadian->jenis_kejadian,
            'lokasi' => $kejadian->lokasi,
        ]));
    }

    public function update(UpdateKejadianKendaraanRequest $request, KejadianKendaraan $kejadian)
    {
        $data = $request->validated();

        // Convert empty strings to null for nullable fields
        foreach (['jenis_kejadian', 'kontak_pihak_ketiga', 'lokasi', 'deskripsi'] as $field) {
            if (array_key_exists($field, $data) && $data[$field] === '') {
                $data[$field] = null;
            }
        }

        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                // Ganti foto lama dengan foto baru
                $this->photoService->delete($kejadian->$field);
                $data[$field] = $this->photoService->upload($request->file($field), 'kejadian');
            } elseif ($request->input('delete_' . $field) == '1' || $request->input('delete_' . $field) === true) {
                // Hapus foto tanpa ganti
                $this->photoService->delete($kejadian->$field);
                $data[$field] = null;
            }
        }

        $kejadian->update($data);
        $kejadian->refresh(); // Ensure new fields are loaded from DB
        $kejadian->load('kendaraan');

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
