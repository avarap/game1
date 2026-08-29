extends Node

const SAVE_VERSION := 1
const DEFAULT_SAVE_PATH := "user://savegame.json"

func save_game(path: String = DEFAULT_SAVE_PATH) -> bool:
    var payload := {
        "save_version": SAVE_VERSION,
        "player": {},
        "world": {},
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

func load_game(path: String = DEFAULT_SAVE_PATH) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        GameLogger.error("Unable to read save path: %s" % path)
        return {}

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        GameLogger.error("Save file is not a dictionary")
        return {}

    if int(parsed.get("save_version", -1)) != SAVE_VERSION:
        GameLogger.warn("Save version requires migration")

    var time_data: Dictionary = parsed.get("time", {})
    TimeManager.day = int(time_data.get("day", 1))
    TimeManager.set_time(int(time_data.get("hour", 6)), int(time_data.get("minute", 0)))
    EventBus.load_completed.emit(path)
    return parsed
