<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * List semua user (kecuali super_admin).
     */
    public function index()
    {
        $users = User::where('role', '!=', 'super_admin')
            ->orderBy('name')
            ->get(['id', 'name', 'email', 'role', 'created_at']);

        return response()->json([
            'success' => true,
            'data'    => $users,
        ]);
    }

    /**
     * Buat user baru. Role tidak boleh super_admin.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'role'     => ['required', Rule::in(['admin', 'manager', 'staff'])],
        ]);

        $user = User::create([
            'name'     => $validated['name'],
            'email'    => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role'     => $validated['role'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User berhasil dibuat.',
            'data'    => $user->only(['id', 'name', 'email', 'role']),
        ], 201);
    }

    /**
     * Update user. Tidak bisa mengubah role ke super_admin.
     */
    public function update(Request $request, User $user)
    {
        // Tidak boleh edit akun super_admin
        if ($user->role === 'super_admin') {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat mengedit akun Super Admin.',
            ], 403);
        }

        $validated = $request->validate([
            'name'     => 'sometimes|string|max:255',
            'email'    => ['sometimes', 'email', Rule::unique('users', 'email')->ignore($user->id)],
            'password' => 'sometimes|string|min:6|nullable',
            'role'     => ['sometimes', Rule::in(['admin', 'manager', 'staff'])],
        ]);

        if (isset($validated['password']) && $validated['password']) {
            $validated['password'] = Hash::make($validated['password']);
        } else {
            unset($validated['password']);
        }

        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'User berhasil diperbarui.',
            'data'    => $user->fresh()->only(['id', 'name', 'email', 'role']),
        ]);
    }

    /**
     * Hapus user. Tidak bisa hapus super_admin.
     */
    public function destroy(User $user)
    {
        if ($user->role === 'super_admin') {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat menghapus akun Super Admin.',
            ], 403);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User berhasil dihapus.',
        ]);
    }
}
