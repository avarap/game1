extends Node

const SAVE_VERSION := 1
const DEFAULT_SAVE_PATH := "user://savegame.json"


func save_game(path: String = DEFAULT_SAVE_PATH, world_override: Dictionary = {}) -> bool:
	var world_data := _collect_world_state()
	if not world_override.is_empty():
		world_data = world_override.duplicate(true)

	var payload := {
		"save_version": SAVE_VERSION,
		"player": _collect_player_state(),
		"world": world_data,
		"quests": {},
		"time": TimeManager.snapshot()
	}

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		GameLogger.error("Unable to open save path: %s" % path)
		return false

	file.store_string(JSON.stringify(payload, "  "))
	EventBus.save_completed.emit(path)
	return true


func load_game(path: String = DEFAULT_SAVE_PATH, apply_world_state: bool = true) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		GameLogger.error("Unable to read save path: %s" % path)
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		GameLogger.error("Save file is not a dictionary")
		return {}

	var payload: Dictionary = parsed
	if int(payload.get("save_version", -1)) != SAVE_VERSION:
		GameLogger.warn("Save version requires migration")

	var time_data: Dictionary = payload.get("time", {})
	TimeManager.apply_snapshot(time_data)

	if apply_world_state:
		var player_data: Dictionary = payload.get("player", {})
		_apply_player_state(player_data)
		var world_data: Dictionary = payload.get("world", {})
		_apply_world_state(world_data)

	EventBus.load_completed.emit(path)
	return payload


func _collect_player_state() -> Dictionary:
	var player := _get_player()
	if player == null:
		return {}
	var player_data: Dictionary = {}
	var inventory := player.get_inventory_component()
	if inventory != null and inventory.model != null:
		var stacks: Array[Dictionary] = []
		for stack in inventory.model.stacks:
			stacks.append({"item_path": stack.item.resource_path, "amount": stack.amount})
		player_data["inventory"] = {
			"capacity_slots": inventory.model.capacity_slots, "stacks": stacks
		}
	var energy := player.get_energy_component()
	if energy != null:
		player_data["energy"] = {
			"current_energy": energy.current_energy, "max_energy": energy.max_energy
		}
	return player_data


func _apply_player_state(player_data: Dictionary) -> void:
	if player_data.is_empty():
		return
	var player := _get_player()
	if player == null:
		return
	var inventory := player.get_inventory_component()
	var inventory_data: Dictionary = player_data.get("inventory", {})
	if inventory != null and not inventory_data.is_empty():
		_apply_inventory_state(inventory, inventory_data)
	var energy := player.get_energy_component()
	var energy_data: Dictionary = player_data.get("energy", {})
	if energy != null and not energy_data.is_empty():
		energy.max_energy = maxi(int(energy_data.get("max_energy", energy.max_energy)), 1)
		energy.current_energy = clampi(
			int(energy_data.get("current_energy", energy.current_energy)), 0, energy.max_energy
		)
		energy.energy_changed.emit(energy.current_energy, energy.max_energy)


func _apply_inventory_state(inventory: InventoryComponent, data: Dictionary) -> void:
	inventory.capacity_slots = maxi(int(data.get("capacity_slots", inventory.capacity_slots)), 0)
	if inventory.model == null:
		inventory.model = InventoryModel.new(inventory.capacity_slots)
	inventory.model.capacity_slots = inventory.capacity_slots
	inventory.model.clear()
	for stack_data: Dictionary in data.get("stacks", []):
		var item_path := str(stack_data.get("item_path", ""))
		if not ResourceLoader.exists(item_path):
			continue
		var item := load(item_path) as ItemData
		inventory.model.add_item(item, int(stack_data.get("amount", 0)))
	inventory.inventory_changed.emit()


func _get_player() -> PlayerController:
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group("player") as PlayerController


func _collect_world_state() -> Dictionary:
	var world_state: Dictionary = {}
	if not is_inside_tree():
		return world_state

	for provider in get_tree().get_nodes_in_group("save_provider"):
		if not provider.has_method("get_save_key") or not provider.has_method("get_save_data"):
			continue
		var key_value: Variant = provider.call("get_save_key")
		var data_value: Variant = provider.call("get_save_data")
		if typeof(data_value) != TYPE_DICTIONARY:
			continue
		world_state[str(key_value)] = data_value
	return world_state


func _apply_world_state(world_state: Dictionary) -> void:
	if not is_inside_tree():
		return

	for provider in get_tree().get_nodes_in_group("save_provider"):
		if not provider.has_method("get_save_key") or not provider.has_method("apply_save_data"):
			continue
		var key := str(provider.call("get_save_key"))
		if not world_state.has(key):
			continue
		var provider_data: Variant = world_state.get(key, {})
		if typeof(provider_data) == TYPE_DICTIONARY:
			provider.call("apply_save_data", provider_data)
