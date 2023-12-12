<?php
namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Response;

class ResponseServiceProvider extends ServiceProvider
{

    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        $provider = $this;

        Response::macro('error', function ($errors, string $message = '', int $code = 404) use ($provider) {
            if (is_string($errors) && empty($message)) {
                $message = $errors;
                $errors = '';
            }
            if (empty($message)) $message = trans('messages.http.' . $code);
            if (!empty($errors)) $errors = $provider->checkResource($errors);

            $data = compact('errors', 'code', 'message');
            return $provider->apiResponse($data);
        });

        Response::macro('success', function ($data = [], string $message = '', int $code = 200)  use ($provider) {
            if ($data instanceof \Illuminate\Pagination\LengthAwarePaginator) {
                $items = collect($data->items());
                $data = $data->toArray();
                $data['data'] = $provider->checkCollection($items);
            } elseif (is_string($data)) {
                $message = $data;
                $data = [];
            } else {
                $data = $provider->checkCollection($data);
            }

            // ??
            if (is_array($data) && !empty($data)) {
                foreach ($data as $key => $value) {
                    $data[$key] = $provider->checkResource($value);
                }
            } else {
                $data = $provider->checkResource($data);
            }

            if (request()->method() == 'PUT') $code = 201;
            if (request()->method() == 'DELETE') $code = 202;

            $data = compact('data', 'code', 'message');
            return $provider->apiResponse($data);
        });
    }

    public function apiResponse(array $data)
    {
        $headers = [
            'Accept' => 'application/json',
            'Content-Type' => 'application/json;charset=utf-8',
        ];
        $code = $data['code'];
        $in_error = boolval($code >= 300 && $code < 1000);
        $json = array_merge(
            $data,
            [
                'success'	=> !$in_error,
                'status'	=> ($in_error ? 'error' : 'success'),
            ]
        );
        ksort($json);

        return response()->json($json, $code, $headers, JSON_UNESCAPED_UNICODE);
    }

    public function checkCollection($data)
    {
        if ($data instanceof \Illuminate\Database\Eloquent\Collection || $data instanceof \Illuminate\Support\Collection) {
            $item = $data->first();
            if ($item instanceof \Illuminate\Database\Eloquent\Model) {
                $model_name = preg_replace('/^.+\\\\/', '', get_class($item));
                $resource_classname = '\\App\\Http\\Resources\\' . $model_name . 'Resource';
                if (class_exists($resource_classname)) {
                    $data = $resource_classname::collection($data);
                }
            }
        }

        return $data;
    }

    public function checkResource($data)
    {
        if ($data instanceof \Illuminate\Database\Eloquent\Model) {
            $model_name = preg_replace('/^.+\\\\/', '', get_class($data));
            $resource_classname = '\\App\\Http\\Resources\\' . $model_name . 'Resource';
            if (class_exists($resource_classname)) {
                $data = new $resource_classname($data);
                $data = $data->resolve();
            }
        } elseif (is_array($data) && !empty($data)) {
            foreach ($data as $key => $value) {
                $data[$key] = $this->checkResource($value);
            }
        }
        return $data;
    }
}
