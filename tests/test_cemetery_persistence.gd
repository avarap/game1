class_name TestCemeteryPersistence
extends RefCounted

static func run() -> Array[String]:
    var failures: Array[String] = []
    var config := load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
    if config == null:
        failures.append("Cemetery rating config should load for persistence test")
        return failures

    var model := CemeteryModel.new(config)
    var service := CemeteryService.new(model)

    var buried_data := CorpseData.new()
    buried_data.id = &"buried_saved"
    buried_data.quality = 3
    buried_data.decay = 0.2
    buried_data.burial_value = 4
    var buried := CorpseState.new(buried_data, 0.03)
    buried.prepare(2)
    service.receive_corpse(buried)
    service.bury_corpse(&"buried_saved")
    service.install_headstone(0)
    service.install_fence(0)
    service.add_decoration(0, 1)

    var pending_data := CorpseData.new()
    pending_data.id = &"pending_saved"
    pending_data.quality = 1
    pending_data.decay = 0.35
    pending_data.burial_value = 2
    var pending := CorpseState.new(pending_data, 0.04)
    pending.prepare(1)
    pending.advance_decay(1.0)
    service.receive_corpse(pending)

    var snapshot := service.snapshot()
    var restored := CemeteryService.from_snapshot(config, snapshot)
    if restored.model.graves.size() != 1 or restored.pending_corpses.size() != 1:
        failures.append("Cemetery snapshot should restore graves and pending corpses")
        return failures
    if restored.total_rating() != service.total_rating():
        failures.append("Restored cemetery should preserve rating")

    var restored_grave := restored.model.graves[0]
    if not restored_grave.has_headstone or not restored_grave.has_fence or restored_grave.decoration_count != 1:
        failures.append("Restored grave should preserve upgrades")
    if restored_grave.corpse.current_preparation_level != 2 or restored_grave.corpse.data.quality != 3:
        failures.append("Restored buried corpse should preserve preparation and quality")

    var restored_pending := restored.pending_corpses.get(&"pending_saved") as CorpseState
    if restored_pending == null:
        failures.append("Pending corpse should restore by id")
    elif absf(restored_pending.current_decay - 0.39) > 0.001 or restored_pending.current_preparation_level != 1:
        failures.append("Pending corpse should preserve decay and preparation")

    var save_path := "user://phase4_cemetery_test.json"
    var world_data := {"cemetery": snapshot}
    if not SaveManager.save_game(save_path, world_data):
        failures.append("SaveManager should persist cemetery world data")
        return failures

    var payload := SaveManager.load_game(save_path, false)
    var loaded_world: Dictionary = payload.get("world", {})
    var loaded_cemetery: Dictionary = loaded_world.get("cemetery", {})
    var loaded_service := CemeteryService.from_snapshot(config, loaded_cemetery)
    if loaded_service.model.graves.size() != 1 or loaded_service.pending_corpses.size() != 1:
        failures.append("SaveManager round trip should preserve cemetery state")
    if loaded_service.total_rating() != service.total_rating():
        failures.append("SaveManager round trip should preserve cemetery rating")

    var absolute_path := ProjectSettings.globalize_path(save_path)
    if FileAccess.file_exists(save_path):
        DirAccess.remove_absolute(absolute_path)

    return failures
