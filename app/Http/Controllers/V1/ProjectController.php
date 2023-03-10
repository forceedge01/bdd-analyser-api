<?php

namespace App\Http\Controllers\V1;

use Illuminate\Http\Request;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use App\Events\ProjectCreatedEvent;
use App\Models\User;

class ProjectController extends Controller
{
    public static $createInputs = [
        'name' => 'required|string',
    ];

    public static $updateInputs = [
        'name' => 'required|string',
    ];

    /**
     * Add user id to the doc block.
     */
    public static function createInputRules(): array
    {
        return array_merge(parent::createInputRules(), ['user_id' => 'required|int']);
    }

    public function beforeCreate(Request $request, array $input): array
    {
        $request->validate(['user_id' => 'required|int']);

        $input['enabled'] = true;

        return $input;
    }

    public function findByCriteria(Request $request, string $model): Builder
    {
        $projects = $model::whereRelation('users', 'user_id', $request->user()->id);

        if ($request->input('name')) {
            $projects->where('name', '=', $request->input('name'));
        }

        return $projects;
    }

    public function afterCreate(Request $request, Model $model): void
    {
        $model->users()->attach($request->input('user_id'));
    }
}
