<?php
namespace App\Providers;

use Blade;
use Illuminate\Support\ServiceProvider;

class ViewServiceProvider extends ServiceProvider
{
    public function boot()
    {
        Blade::if('notempty', function ($data) {
            return (!empty($data));
        });
    }
}
