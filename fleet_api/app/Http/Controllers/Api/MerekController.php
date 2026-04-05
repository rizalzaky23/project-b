<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Merek;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class MerekController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $mereks = Merek::orderBy('nama', 'asc')->get();
        return $this->successResponse($mereks);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:100|unique:mereks,nama',
        ]);

        $merek = Merek::create([
            'nama' => $request->nama,
        ]);

        return $this->createdResponse($merek, 'Merek berhasil ditambahkan.');
    }

    public function show(Merek $merek)
    {
        return $this->successResponse($merek);
    }

    public function update(Request $request, Merek $merek)
    {
        $request->validate([
            'nama' => 'required|string|max:100|unique:mereks,nama,' . $merek->id,
        ]);

        $merek->update([
            'nama' => $request->nama,
        ]);

        return $this->successResponse($merek, 'Merek berhasil diperbarui.');
    }

    public function destroy(Merek $merek)
    {
        $merek->delete();
        return $this->successResponse(null, 'Merek berhasil dihapus.');
    }
}
