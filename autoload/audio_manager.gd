extends Node

const REQUIRED_BUSES := ["Music", "Ambient", "SFX", "UI"]

func _ready() -> void:
    _ensure_audio_buses()

func _ensure_audio_buses() -> void:
    for bus_name in REQUIRED_BUSES:
        if AudioServer.get_bus_index(bus_name) == -1:
            AudioServer.add_bus()
            var index := AudioServer.bus_count - 1
            AudioServer.set_bus_name(index, bus_name)
