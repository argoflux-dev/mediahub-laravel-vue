<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    abort(404);
});

Route::get('/health', fn() => ['status' => 'ok']);
