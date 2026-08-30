class_name TestStorageNetwork
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var recipe := load("res://data/recipes/wood_to_plank.tres") as RecipeData
	var wood := load("res://data/items/wood.tres") as ItemData
	if recipe == null or wood == null:
		failures.append("StorageNetwork test data should load")
		return failures

	var player_inventory := InventoryModel.new(2)
	var chest_inventory := InventoryModel.new(2)
	player_inventory.add_item(wood, 1)
	chest_inventory.add_item(wood, 1)

	var network := StorageNetwork.new()
	network.add_provider(StorageProvider.new(&"player", player_inventory))
	network.add_provider(StorageProvider.new(&"chest", chest_inventory))

	if not network.has_item(&"wood", 2) or network.get_available_amount(&"wood") != 2:
		failures.append("StorageNetwork should aggregate item availability across providers")
	if network.find_sources(&"wood").size() != 2:
		failures.append("StorageNetwork should report all providers containing an item")

	var result := CraftingService.craft_with_storage(recipe, &"workbench", network)
	if result != CraftingService.RESULT_OK:
		failures.append("Crafting should consume inputs across compatible storage providers")
	if player_inventory.count_item(&"wood") != 0 or chest_inventory.count_item(&"wood") != 0:
		failures.append("Distributed crafting should consume wood from both providers")
	if player_inventory.count_item(&"plank") != 1:
		failures.append("Crafting output should deposit through StorageNetwork")

	var scoped_inventory := InventoryModel.new(2)
	var workshop_provider := StorageProvider.new(&"workshop_chest", scoped_inventory, &"workshop")
	if not workshop_provider.matches_scope(&"workshop"):
		failures.append("StorageProvider should match its configured scope")
	if workshop_provider.matches_scope(&"mine"):
		failures.append("StorageProvider should reject unrelated storage scopes")

	var insufficient_player := InventoryModel.new(2)
	var insufficient_chest := InventoryModel.new(2)
	insufficient_chest.add_item(wood, 1)
	var insufficient_network := StorageNetwork.new()
	insufficient_network.add_provider(StorageProvider.new(&"player", insufficient_player))
	insufficient_network.add_provider(StorageProvider.new(&"chest", insufficient_chest))
	result = CraftingService.craft_with_storage(recipe, &"workbench", insufficient_network)
	if result != CraftingService.RESULT_MISSING_INPUTS:
		failures.append("Distributed crafting should reject missing aggregate inputs")
	if insufficient_chest.count_item(&"wood") != 1:
		failures.append("Rejected distributed crafting must not mutate providers")

	var chest_scene := load("res://world/storage/storage_chest.tscn") as PackedScene
	var player_scene := load("res://player/player.tscn") as PackedScene
	var station_scene := load("res://world/buildings/workbench.tscn") as PackedScene
	if chest_scene == null or player_scene == null or station_scene == null:
		failures.append("Player, workbench and storage chest scenes should load")
		return failures

	var player := player_scene.instantiate() as PlayerController
	var station := station_scene.instantiate() as CraftingStation
	var chest := chest_scene.instantiate() as StorageChest
	var actor_inventory := player.get_inventory_component()
	var energy := player.get_energy_component()
	var chest_component := chest.get_inventory_component()
	actor_inventory._ready()
	energy._ready()
	chest_component._ready()

	actor_inventory.add_item(wood, 1)
	chest_component.add_item(wood, 1)
	station.register_storage_provider(chest.get_storage_provider())
	station.interact(player)

	if station.last_result != CraftingService.RESULT_OK:
		failures.append("Workbench should consume from a compatible registered storage provider")
	if actor_inventory.count_item(&"plank") != 1:
		failures.append("Workbench should deposit output through its StorageNetwork")
	if chest_component.count_item(&"wood") != 0:
		failures.append("Workbench should consume required input from compatible chest storage")
	if energy.current_energy != 98:
		failures.append("Distributed crafting should preserve the configured energy cost")

	var remote_inventory := InventoryModel.new(2)
	remote_inventory.add_item(wood, 2)
	station.clear_registered_storage_providers()
	station.register_storage_provider(StorageProvider.new(&"remote", remote_inventory, &"mine"))
	station.interact(player)
	if station.last_result != CraftingService.RESULT_MISSING_INPUTS:
		failures.append("Workbench should ignore registered providers from another storage scope")
	if remote_inventory.count_item(&"wood") != 2:
		failures.append("Out-of-scope storage must remain untouched")

	chest.free()
	station.free()
	player.free()
	return failures
