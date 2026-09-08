class_name TestPlayerPersistence
extends RefCounted

const MAIN_PATH := "res://main.tscn"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var main_scene := load(MAIN_PATH) as PackedScene
	var save_manager := tree.root.get_node_or_null("SaveManager")
	if main_scene == null or save_manager == null:
		failures.append("Player persistence requires the real main scene and SaveManager")
		return failures
	var save_path := "user://test_player_persistence_%d.json" % OS.get_process_id()
	var wood := load("res://data/items/wood.tres") as ItemData
	var game := main_scene.instantiate()
	tree.root.add_child(game)
	var saved := _save_player_state(game, save_manager, save_path, wood, failures)
	game.free()
	if saved:
		game = main_scene.instantiate()
		tree.root.add_child(game)
		_check_round_trip(game, save_manager, save_path, wood, failures)
		_check_legacy_save(game, save_manager, save_path, failures)
		game.free()
	if FileAccess.file_exists(save_path):
		if DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path)) != OK:
			failures.append("Player persistence should remove its isolated test save")
	return failures


static func _save_player_state(
	game: Node, save_manager: Node, save_path: String, wood: ItemData, failures: Array[String]
) -> bool:
	var player := game.get_node("World/Player") as PlayerController
	var inventory := player.get_inventory_component()
	var energy := player.get_energy_component()
	var quests := game.get_node("World/QuestController") as QuestController
	var plank := load("res://data/items/plank.tres") as ItemData
	var seed := load("res://data/farming/fodder_turnip_seed.tres") as ItemData
	inventory.capacity_slots = 6
	inventory.model.capacity_slots = 6
	if (
		inventory.add_item(wood, 23) != 0
		or inventory.add_item(plank, 2) != 0
		or inventory.add_item(seed, 4) != 0
	):
		failures.append("Player persistence setup should add all real item resources")
		return false
	energy.max_energy = 150
	energy.restore(50)
	if not energy.spend(63) or energy.current_energy != 87:
		failures.append("Player persistence setup should leave exactly 87 of 150 energy")
		return false
	if not quests.start_quest(&"aldren_first_duty") or not quests.is_ready(&"aldren_first_duty"):
		failures.append("Player persistence setup should make the saved plank quest ready")
		return false
	if not bool(save_manager.call("save_game", save_path)):
		failures.append("SaveManager should write the real main-scene player state")
		return false
	var persisted: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if persisted.get("player", {}).is_empty():
		failures.append("The save file should contain player data instead of an empty placeholder")
	return true


static func _check_round_trip(
	game: Node, save_manager: Node, save_path: String, wood: ItemData, failures: Array[String]
) -> void:
	var player := game.get_node("World/Player") as PlayerController
	var inventory := player.get_inventory_component()
	var energy := player.get_energy_component()
	var quests := game.get_node("World/QuestController") as QuestController
	var model_before := inventory.model
	inventory.add_item(wood, 1)
	inventory.add_item(load("res://data/items/fodder_turnip_mash.tres") as ItemData, 1)
	energy.spend(5)
	var changes := {"inventory": 0, "energy": 0}
	inventory.inventory_changed.connect(func(): changes["inventory"] += 1)
	energy.energy_changed.connect(func(_current, _maximum): changes["energy"] += 1)
	var payload: Dictionary = save_manager.call("load_game", save_path, false)
	if payload.is_empty():
		failures.append("Player save should be readable from the isolated file")
	if inventory.count_item(&"wood") != 1 or energy.current_energy != 95:
		failures.append("Loading without applying state should leave the live player unchanged")
	if changes["inventory"] != 0 or changes["energy"] != 0:
		failures.append("Loading without applying state should not emit player changes")
	save_manager.call("load_game", save_path, true)
	_assert_restored_state(inventory, energy, failures)
	if inventory.count_item(&"fodder_turnip_mash") != 0:
		failures.append("Loading should replace unsaved inventory contents")
	if inventory.capacity_slots != 6 or inventory.model.capacity_slots != 6:
		failures.append("Save/load should restore inventory capacity with the contents")
	if inventory.model != model_before:
		failures.append("Loading should preserve the inventory model held by storage consumers")
	if changes["inventory"] != 1 or changes["energy"] != 1:
		failures.append("Restoring player state should notify inventory and energy consumers once")
	if not quests.is_ready(&"aldren_first_duty"):
		failures.append("Restored quest readiness should use the restored player inventory")
	save_manager.call("load_game", save_path, true)
	_assert_restored_state(inventory, energy, failures)
	if changes["inventory"] != 2 or changes["energy"] != 2:
		failures.append("Each applied load should emit exactly one inventory and energy change")


static func _assert_restored_state(
	inventory: InventoryComponent, energy: EnergyComponent, failures: Array[String]
) -> void:
	if inventory.count_item(&"wood") != 23:
		failures.append("Save/load after recreating main.tscn should restore 23 wood across stacks")
	if inventory.count_item(&"plank") != 2 or inventory.count_item(&"fodder_turnip_seed") != 4:
		failures.append("Save/load should restore both plank and farming-seed resources")
	if inventory.model.stacks.size() != 4:
		failures.append("Restored items should retain their authored stack limits")
	if energy.current_energy != 87 or energy.max_energy != 150:
		failures.append("Save/load after recreating main.tscn should restore 87 of 150 energy")


static func _check_legacy_save(
	game: Node, save_manager: Node, save_path: String, failures: Array[String]
) -> void:
	var player := game.get_node("World/Player") as PlayerController
	var inventory := player.get_inventory_component()
	var energy := player.get_energy_component()
	inventory.remove_item(&"wood", 5)
	energy.spend(3)
	var changes := {"inventory": 0, "energy": 0}
	inventory.inventory_changed.connect(func(): changes["inventory"] += 1)
	energy.energy_changed.connect(func(_current, _maximum): changes["energy"] += 1)
	var payload: Dictionary = save_manager.call("load_game", save_path, false)
	payload["save_version"] = 1
	for omit_player in [false, true]:
		if omit_player:
			payload.erase("player")
		else:
			payload["player"] = {}
		var file := FileAccess.open(save_path, FileAccess.WRITE)
		if file == null:
			failures.append("Legacy player save fixture should open at the isolated path")
			return
		file.store_string(JSON.stringify(payload))
		file.close()
		save_manager.call("load_game", save_path, true)
		if inventory.count_item(&"wood") != 18 or energy.current_energy != 84:
			failures.append("Version-1 saves without player data should preserve the live player")
		if inventory.capacity_slots != 6 or energy.max_energy != 150:
			failures.append("Legacy saves should preserve the live inventory and energy capacities")
		if changes["inventory"] != 0 or changes["energy"] != 0:
			failures.append("Legacy saves without player data should not notify player changes")
