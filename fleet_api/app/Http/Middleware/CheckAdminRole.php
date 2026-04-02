<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckAdminRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Allow GET requests for everyone (Read-only)
        if ($request->isMethod('GET')) {
            return $next($request);
        }

        // For POST, PUT, PATCH, DELETE, check if user is admin or super_admin
        if ($request->user() && in_array($request->user()->role, ['admin', 'super_admin'])) {
            return $next($request);
        }

        // Otherwise return 403 Forbidden
        return response()->json([
            'success' => false,
            'message' => 'Akses ditolak. Anda tidak memiliki izin untuk melakukan aksi ini.',
        ], 403);
    }
}
