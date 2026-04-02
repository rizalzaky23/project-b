<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckSuperAdminRole
{
    /**
     * Hanya super_admin yang bisa mengakses endpoint ini.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user() && $request->user()->role === 'super_admin') {
            return $next($request);
        }

        return response()->json([
            'success' => false,
            'message' => 'Akses ditolak. Hanya Super Admin yang dapat mengelola user.',
        ], 403);
    }
}
