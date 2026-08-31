class_name TestAudioBaseline
extends RefCounted

const REQUIRED_BUSES := ["Master", "Music", "Ambience", "SFX"]


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_bus_routing(failures)
	_check_audio_resources(failures)
	_check_feedback_listener(failures)
	_check_ambience_profiles(failures)
	return failures


static func _check_bus_routing(failures: Array[String]) -> void:
	for bus_name in REQUIRED_BUSES:
		var index := AudioServer.get_bus_index(bus_name)
		if index < 0:
			failures.append("Audio bus %s should exist" % bus_name)
			continue
		var volume_db := AudioServer.get_bus_volume_db(index)
		if volume_db > 0.0 or volume_db < -18.0:
			failures.append("Audio bus %s should use a conservative initial mix" % bus_name)


static func _check_audio_resources(failures: Array[String]) -> void:
	if not ResourceLoader.exists("res://audio/synthesis/audio_library.gd"):
		failures.append("Procedural audio library should exist")
		return
	var streams: Array[AudioStream] = [
		AudioLibrary.cemetery_ambience(),
		AudioLibrary.interior_ambience(),
		AudioLibrary.funeral_delivery(),
		AudioLibrary.decision_cremate(),
		AudioLibrary.decision_research(),
		AudioLibrary.graveyard_theme(),
	]
	for stream in streams:
		if stream == null:
			failures.append("Every baseline audio asset should generate a valid AudioStream")
			break
	if not FileAccess.file_exists("res://audio/ASSET_LICENSES.md"):
		failures.append("Audio assets should include provenance and license metadata")


static func _check_feedback_listener(failures: Array[String]) -> void:
	var script_path := "res://audio/listeners/audio_event_listener.gd"
	if not ResourceLoader.exists(script_path):
		failures.append("Audio event listener should exist")
		return
	var script := load(script_path) as Script
	var listener := script.new() as Node
	var tree := Engine.get_main_loop() as SceneTree
	if listener == null or tree == null:
		failures.append("Audio event listener should instantiate safely")
		return
	tree.root.add_child(listener)
	var player := listener.get_node_or_null("FeedbackPlayer") as AudioStreamPlayer
	if player == null:
		failures.append("Audio event listener should own a feedback player")
		listener.free()
		return
	var event_bus := tree.root.get_node_or_null("EventBus")
	if event_bus == null:
		failures.append("Audio tests require the EventBus autoload")
		listener.free()
		return
	event_bus.emit_signal("funeral_delivery_completed", &"audio_test", 1, &"roadside_dropoff")
	if player.stream == null or player.bus != "SFX":
		failures.append("Funeral delivery feedback should route to SFX")
	var delivery_stream := player.stream
	event_bus.emit_signal("corpse_final_decision_completed", &"audio_test", &"research", 0, 1, 0)
	if player.stream == null or player.stream == delivery_stream:
		failures.append("Terminal decision feedback should select decision-specific SFX")
	listener.free()


static func _check_ambience_profiles(failures: Array[String]) -> void:
	var script_path := "res://audio/listeners/audio_ambience_presenter.gd"
	if not ResourceLoader.exists(script_path):
		failures.append("Audio ambience presenter should exist")
		return
	var script := load(script_path) as Script
	var presenter := script.new() as Node
	var tree := Engine.get_main_loop() as SceneTree
	if presenter == null or tree == null:
		failures.append("Audio ambience presenter should instantiate safely")
		return
	tree.root.add_child(presenter)
	presenter.call("apply_zone", &"cemetery")
	var player := presenter.get_node_or_null("AmbiencePlayer") as AudioStreamPlayer
	if player == null or player.stream == null or player.bus != "Ambience":
		failures.append("Cemetery ambience should route to Ambience")
		presenter.free()
		return
	var cemetery_stream := player.stream
	presenter.call("apply_zone", &"home_interior")
	if player.stream == null or player.stream == cemetery_stream:
		failures.append("Interior zones should use differentiated ambience")
	presenter.free()
