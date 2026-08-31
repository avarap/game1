extends Node

const BUS_LEVELS_DB := {
	"Master": -2.0,
	"Music": -10.0,
	"Ambience": -12.0,
	"SFX": -6.0,
}
const EVENT_LISTENER_SCRIPT := preload("res://audio/listeners/audio_event_listener.gd")
const AMBIENCE_PRESENTER_SCRIPT := preload("res://audio/listeners/audio_ambience_presenter.gd")

var _music_player: AudioStreamPlayer


func _ready() -> void:
	_ensure_audio_buses()
	_install_audio_presenters()
	_start_music()


func _ensure_audio_buses() -> void:
	for bus_name in BUS_LEVELS_DB:
		var index := AudioServer.get_bus_index(bus_name)
		if index == -1:
			AudioServer.add_bus()
			index = AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_volume_db(index, float(BUS_LEVELS_DB[bus_name]))


func _install_audio_presenters() -> void:
	var event_listener := EVENT_LISTENER_SCRIPT.new() as Node
	event_listener.name = "AudioEventListener"
	add_child(event_listener)
	var ambience_presenter := AMBIENCE_PRESENTER_SCRIPT.new() as Node
	ambience_presenter.name = "AudioAmbiencePresenter"
	add_child(ambience_presenter)


func _start_music() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Music"
	_music_player.stream = AudioLibrary.graveyard_theme()
	add_child(_music_player)
	_music_player.play()
