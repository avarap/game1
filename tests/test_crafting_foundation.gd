class_name TestCraftingFoundation
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var recipe := load("res://data/recipes/wood_to_plank.tres") as RecipeData
	var wood := load("res://data/items/wood.tres") as ItemData
	var plank := load("res://data/items/plank.tres") as ItemData
	if recipe == null or wood == null or plank == null or not recipe.is_valid():
		failures.append("Phase 3 recipe data should load and validate")
		return failures

	var inventory := InventoryModel.new(3)
	inventory.add_item(wood, 4)
	var result := CraftingService.craft(recipe, &"workbench", inventory)
	if result != CraftingService.RESULT_OK:
		failures.append("Workbench recipe should craft with valid inputs")
	if inventory.count_item(&"wood") != 2 or inventory.count_item(&"plank") != 1:
		failures.append("Craft should atomically consume 2 wood and produce 1 plank")

	var wrong_station := InventoryModel.new(3)
	wrong_station.add_item(wood, 2)
	result = CraftingService.craft(recipe, &"furnace", wrong_station)
	if result != CraftingService.RESULT_WRONG_STATION or wrong_station.count_item(&"wood") != 2:
		failures.append("Wrong station must reject crafting without mutation")

	var missing := InventoryModel.new(3)
	missing.add_item(wood, 1)
	result = CraftingService.craft(recipe, &"workbench", missing)
	if result != CraftingService.RESULT_MISSING_INPUTS or missing.count_item(&"wood") != 1:
		failures.append("Missing inputs must reject crafting without mutation")

	var full := InventoryModel.new(1)
	full.add_item(wood, 3)
	result = CraftingService.craft(recipe, &"workbench", full)
	if result != CraftingService.RESULT_INVENTORY_FULL:
		failures.append("Craft should fail when outputs cannot fit")
	if full.count_item(&"wood") != 3 or full.count_item(&"plank") != 0:
		failures.append("Inventory-full craft must remain atomic")

	var player_scene := load("res://player/player.tscn") as PackedScene
	var station_scene := load("res://world/buildings/workbench.tscn") as PackedScene
	if player_scene == null or station_scene == null:
		failures.append("Crafting station and player scenes should load")
		return failures

	var player := player_scene.instantiate() as PlayerController
	var station := station_scene.instantiate() as CraftingStation
	var player_inventory := player.get_node("InventoryComponent") as InventoryComponent
	var energy := player.get_node("EnergyComponent") as EnergyComponent
	player_inventory._ready()
	energy._ready()
	player_inventory.add_item(wood, 2)
	station.interact(player)
	if station.last_result != CraftingService.RESULT_OK:
		failures.append("Workbench interaction should execute configured recipe")
	if player_inventory.count_item(&"plank") != 1 or player_inventory.count_item(&"wood") != 0:
		failures.append("Workbench interaction should mutate player inventory")
	if energy.current_energy != 98:
		failures.append("Successful crafting should consume configured 2 energy")

	station.free()
	player.free()
	return failures
