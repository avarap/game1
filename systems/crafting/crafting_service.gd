class_name CraftingService
extends RefCounted

const RESULT_OK: StringName = &"ok"
const RESULT_INVALID_RECIPE: StringName = &"invalid_recipe"
const RESULT_WRONG_STATION: StringName = &"wrong_station"
const RESULT_MISSING_INPUTS: StringName = &"missing_inputs"
const RESULT_INVENTORY_FULL: StringName = &"inventory_full"

static func craft(recipe: RecipeData, station_id: StringName, inventory: InventoryModel) -> StringName:
    if recipe == null or inventory == null or not recipe.is_valid():
        return RESULT_INVALID_RECIPE
    if recipe.station != station_id:
        return RESULT_WRONG_STATION
    if not _has_inputs(recipe, inventory):
        return RESULT_MISSING_INPUTS

    var simulated := _clone_inventory(inventory)
    for ingredient in recipe.inputs:
        simulated.remove_item(ingredient.item.id, ingredient.amount)
    for ingredient in recipe.outputs:
        var remainder: int = simulated.add_item(ingredient.item, ingredient.amount)
        if remainder > 0:
            return RESULT_INVENTORY_FULL

    inventory.capacity_slots = simulated.capacity_slots
    inventory.stacks = simulated.stacks
    return RESULT_OK

static func _has_inputs(recipe: RecipeData, inventory: InventoryModel) -> bool:
    for ingredient in recipe.inputs:
        if not inventory.has_item(ingredient.item.id, ingredient.amount):
            return false
    return true

static func _clone_inventory(source: InventoryModel) -> InventoryModel:
    var copy := InventoryModel.new(source.capacity_slots)
    for stack in source.stacks:
        copy.add_item(stack.item, stack.amount)
    return copy
