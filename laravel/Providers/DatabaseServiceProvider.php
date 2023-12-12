<?php
namespace App\Providers;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\ServiceProvider;

class DatabaseServiceProvider extends ServiceProvider
{
	/**
	 * Register services.
	 *
	 * @return void
	 */
	public function register()
	{
		//
	}

	/**
	 * Bootstrap services.
	 *
	 * @return void
	 */
	public function boot()
	{
		Schema::defaultStringLength(191);

		Builder::macro('whereEmpty', function ($column) {
			return $this->where(function ($q) use ($column) {
				$q
					->whereNull($column)
					->orWhere($column, '=', '');
			});
		});
		Builder::macro('whereNotEmpty', function ($column) {
			return $this->where(function ($q) use ($column) {
				$q
					->whereNotNull($column)
					->where($column, '!=', '');
			});
		});
		Builder::macro('orWhereEmpty', function ($column) {
			return $this->orWhere(function ($q) use ($column) {
				$q
					->whereNull($column)
					->orWhere($column, '=', '');
			});
		});
		Builder::macro('orWhereNotEmpty', function ($column) {
			return $this->orWhere(function ($q) use ($column) {
				$q
					->whereNotNull($column)
					->where($column, '!=', '');
			});
		});
		Builder::macro('whereLike', function ($column, string $search, bool $start_jolly = true, bool $end_jolly = true) {
			$search =
				($start_jolly ? '%' : '') .
				$search .
				($end_jolly ? '%' : '');
			return $this->where($column, 'LIKE', $search);
		});
		Builder::macro('whereNotLike', function ($column, string $search, bool $start_jolly = true, bool $end_jolly = true) {
			$search =
				($start_jolly ? '%' : '') .
				$search .
				($end_jolly ? '%' : '');
			return $this->where($column, 'NOT LIKE', $search);
		});
		Builder::macro('orWhereLike', function ($column, string $search, bool $start_jolly = true, bool $end_jolly = true) {
			$search =
				($start_jolly ? '%' : '') .
				$search .
				($end_jolly ? '%' : '');
			return $this->orWhere($column, 'LIKE', $search);
		});
		Builder::macro('orWhereNotLike', function ($column, string $search, bool $start_jolly = true, bool $end_jolly = true) {
			$search =
				($start_jolly ? '%' : '') .
				$search .
				($end_jolly ? '%' : '');
			return $this->orWhere($column, 'NOT LIKE', $search);
		});
		Builder::macro('wherePivotLike', function ($column, string $search, bool $start_jolly = true, bool $end_jolly = true) {
			$search =
				($start_jolly ? '%' : '') .
				$search .
				($end_jolly ? '%' : '');
			return $this->wherePivot($column, 'LIKE', $search);
		});
	}
}
