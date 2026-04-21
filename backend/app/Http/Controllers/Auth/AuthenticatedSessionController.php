<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;

class AuthenticatedSessionController extends Controller
{
    /**
     * Handle an incoming authentication request.
     */
    public function store(LoginRequest $request): Response
    {
        $request->authenticate();

        // Token-based authentication
        $user = Auth::user();
        $token = $user->createToken('primary')->plainTextToken;

        return response([
            'user' => $user,
            'token' => $token
        ]);

        // Session-based authentication
        // $request->session()->regenerate();
        // return response()->noContent();
    }

    /**
     * Destroy an authenticated session.
     */
    public function destroy(Request $request): Response
    {
        // Token-based authentication
        $request->user()->currentAccessToken()->delete();

        // Session-based authentication
        // Auth::guard('web')->logout();
        // $request->session()->invalidate();
        // $request->session()->regenerateToken();

        return response()->noContent();
    }
}
