<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ServisKendaraan;
use App\Services\PhotoUploadService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class ServisKendaraanController extends Controller
{
    use ApiResponse;

    private array $photoFields = [
        'foto_km', 'foto_invoice'
    ];

    public function __construct(private PhotoUploadService $photoService) {}

    public function index(Request $request)
    {
        $query = ServisKendaraan::with('kendaraan')
            ->when($request->kendaraan_id, fn($q, $v) => $q->where('kendaraan_id', $v))
            ->latest();

        return $this->paginatedResponse($query->paginate($request->per_page ?? 15));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'kendaraan_id' => 'required|exists:kendaraan,id',
            'tanggal_servis' => 'nullable|date',
            'kilometer' => 'nullable|integer',
            'foto_km' => 'nullable|image|max:5120',
            'foto_invoice' => 'nullable|image|max:5120',
        ]);

        $data = [
            'kendaraan_id' => $validated['kendaraan_id'] ?? null,
            'tanggal_servis' => $validated['tanggal_servis'] ?? null,
            'kilometer' => $validated['kilometer'] ?? 0,
        ];

        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                $data[$field] = $this->photoService->upload($request->file($field), 'servis');
            }
        }

        $servis = ServisKendaraan::create($data);
        $servis->load('kendaraan');

        return $this->createdResponse($servis, 'Data servis berhasil ditambahkan.');
    }

    public function show(ServisKendaraan $servis)
    {
        $servis->load('kendaraan');
        return $this->successResponse($servis);
    }

    public function update(Request $request, ServisKendaraan $servis)
    {
        $validated = $request->validate([
            'tanggal_servis' => 'nullable|date',
            'kilometer' => 'nullable|integer',
            'foto_km' => 'nullable|image|max:5120',
            'foto_invoice' => 'nullable|image|max:5120',
        ]);

        $data = [];
        if ($request->has('tanggal_servis')) {
            $data['tanggal_servis'] = $validated['tanggal_servis'];
        }
        if ($request->has('kilometer')) {
            $data['kilometer'] = $validated['kilometer'];
        }

        foreach ($this->photoFields as $field) {
            if ($request->hasFile($field)) {
                $this->photoService->delete($servis->$field);
                $data[$field] = $this->photoService->upload($request->file($field), 'servis');
            } elseif ($request->input('delete_' . $field) == '1') {
                $this->photoService->delete($servis->$field);
                $data[$field] = null;
            }
        }

        $servis->update($data);
        $servis->load('kendaraan');

        return $this->successResponse($servis, 'Data servis berhasil diperbarui.');
    }

    public function destroy(ServisKendaraan $servis)
    {
        $this->photoService->deleteMany(array_filter(
            array_map(fn($f) => $servis->$f, $this->photoFields)
        ));

        $servis->delete();

        return $this->successResponse(null, 'Data servis berhasil dihapus.');
    }
}
