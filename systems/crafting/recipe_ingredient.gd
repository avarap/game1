class_name RecipeIngredient
extends Resource

@export var item: ItemData
@export_range(1, 999, 1) var amount: int = 1

func is_valid() -> bool:
    return item != null and item.is_valid() and amount > 0
