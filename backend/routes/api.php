<?php

use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\ImageController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])
    ->group(function () {
        Route::post('/logout', [AuthenticatedSessionController::class, 'destroy']);

        Route::get('/user', function (Request $request) {
            return $request->user();
        });

        Route::apiResource('/image', ImageController::class)
            ->only(['index', 'store', 'destroy']);
    });
