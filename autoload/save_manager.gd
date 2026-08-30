extends Node

const SAVE_VERSION := 1
const DEFAULT_SAVE_PATH := "user://savegame.json"

func save_game(path: String = DEFAULT_SAVE_PATH, world_override: Dictionary = {}) -> bool:
    var world_data := _collect_world_state()
    if not world_override.is_empty():
        world_data = world_override.duplicate(true)

    var payload := {
        "save_version": SAVE_VERSION,
        "player": {},
        "world": world_data,
        "quests": {},
        "time": {
            "day": TimeManager.day,
            "hour": TimeManager.hour,
            "minute": TimeManager.minute
        }
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
    TimeManager.day = int(time_data.get("day", 1))
    TimeManager.set_time(int(time_data.get("hour", 6)), int(time_data.get("minute", 0)))

    if apply_world_state:
        var world_data: Dictionary = payload.get("world", {})
        _apply_world_state(world_data)

    EventBus.load_completed.emit(path)
    return payload

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
