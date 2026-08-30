class_name RecipeData
extends Resource

@export var id: StringName
@export var display_name: String
@export var station: StringName
@export var inputs: Array[RecipeIngredient] = []
@export var outputs: Array[RecipeIngredient] = []
@export_range(0.0, 3600.0, 0.1) var duration_seconds: float = 0.0
@export_range(0, 100, 1) var energy_cost: int = 2

func is_valid() -> bool:
    if id.is_empty() or station.is_empty() or outputs.is_empty():
        return false
    for ingredient in inputs:
        if ingredient == null or not ingredient.is_valid():
            return false
    for ingredient in outputs:
        if ingredient == null or not ingredient.is_valid():
            return false
    return true
