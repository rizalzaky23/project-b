<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\DetailKendaraan\StoreDetailKendaraanRequest;
use App\Http\Requests\DetailKendaraan\UpdateDetailKendaraanRequest;
use App\Models\DetailKendaraan;
use App\Services\PhotoUploadService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class DetailKendaraanController extends Controller
{
    use ApiResponse;

    private array $photoFields = ['foto_stnk', 'foto_bpkb', 'foto_nomor', 'foto_km'];
    private array $pdfFields   = ['kartu_kir', 'lembar_kir'];

    public function __construct(private PhotoUploadService $photoService) {}

    public function index(Request $request)
    {
        $query = DetailKendaraan::with('kendaraan')
            ->when($request->kendaraan_id, fn($q, $v) => $q->where('kendaraan_id', $v))
            ->when($request->search, fn($q, $s) =>
                $q->where('no_polisi', 'like', "%{$s}%")
                  ->orWhere('pemilik_komersial', 'like', "%{$s}%")
            )
            ->latest();

        return $this->paginatedResponse($query->paginate($request->per_page ?? 15));
    }

    public function store(StoreDetailKendaraanRequest $request)
    {
        $data = $request->validated();

        foreach (array_merge($this->photoFields, $this->pdfFields) as $field) {
            if ($request->hasFile($field)) {
                $data[$field] = $this->photoService->upload($request->file($field), 'detail_kendaraan');
            }
        }

        $detail = DetailKendaraan::create($data);
        $detail->load('kendaraan');

        return $this->createdResponse($detail, 'Detail kendaraan berhasil ditambahkan.');
    }

    public function show(DetailKendaraan $detailKendaraan)
    {
        $detailKendaraan->load('kendaraan');
        return $this->successResponse($detailKendaraan);
    }

    public function update(UpdateDetailKendaraanRequest $request, DetailKendaraan $detailKendaraan)
    {
        $data = $request->validated();

        foreach (array_merge($this->photoFields, $this->pdfFields) as $field) {
            if ($request->hasFile($field)) {
                $this->photoService->delete($detailKendaraan->$field);
                $data[$field] = $this->photoService->upload($request->file($field), 'detail_kendaraan');
            } elseif ($request->input('delete_' . $field) == '1' || $request->input('delete_' . $field) === true) {
                $this->photoService->delete($detailKendaraan->$field);
                $data[$field] = null;
            }
        }

        $detailKendaraan->update($data);

        return $this->successResponse($detailKendaraan, 'Detail kendaraan berhasil diperbarui.');
    }

    public function destroy(DetailKendaraan $detailKendaraan)
    {
        $this->photoService->deleteMany(array_filter(
            array_map(fn($f) => $detailKendaraan->$f, array_merge($this->photoFields, $this->pdfFields))
        ));

        $detailKendaraan->delete();

        return $this->successResponse(null, 'Detail kendaraan berhasil dihapus.');
    }
}
