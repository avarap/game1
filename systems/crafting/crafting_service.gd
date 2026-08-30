class_name CraftingService
extends RefCounted

const RESULT_OK: StringName = &"ok"
const RESULT_INVALID_RECIPE: StringName = &"invalid_recipe"
const RESULT_WRONG_STATION: StringName = &"wrong_station"
const RESULT_MISSING_INPUTS: StringName = &"missing_inputs"
const RESULT_INVENTORY_FULL: StringName = &"inventory_full"


static func craft(
	recipe: RecipeData, station_id: StringName, inventory: InventoryModel
) -> StringName:
	if inventory == null:
		return RESULT_INVALID_RECIPE
	var network := StorageNetwork.new()
	network.add_provider(StorageProvider.new(&"inventory", inventory))
	return craft_with_storage(recipe, station_id, network)


static func craft_with_storage(
	recipe: RecipeData, station_id: StringName, storage: StorageNetwork
) -> StringName:
	if recipe == null or storage == null or not recipe.is_valid():
		return RESULT_INVALID_RECIPE
	if recipe.station != station_id:
		return RESULT_WRONG_STATION
	if not _has_inputs(recipe, storage):
		return RESULT_MISSING_INPUTS

	var simulated := storage.clone_network()
	for ingredient in recipe.inputs:
		simulated.consume(ingredient.item.id, ingredient.amount)
	for ingredient in recipe.outputs:
		var remainder: int = simulated.deposit(ingredient.item, ingredient.amount)
		if remainder > 0:
			return RESULT_INVENTORY_FULL

	if not storage.apply_from(simulated):
		return RESULT_INVALID_RECIPE
	return RESULT_OK


static func _has_inputs(recipe: RecipeData, storage: StorageNetwork) -> bool:
	for ingredient in recipe.inputs:
		if not storage.has_item(ingredient.item.id, ingredient.amount):
			return false
	return true
