class_name TestWorldAtmosphere
extends RefCounted

const CONTROLLER_PATH := "res://world/simulation/world_atmosphere_controller.gd"
const SCENE_PATH := "res://world/simulation/world_atmosphere.tscn"
const SHADER_PATH := "res://shaders/atmosphere_canvas.gdshader"
const SWAY_PATH := "res://world/simulation/ambient_vegetation_sway.gd"


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_resources(failures)
	_check_world_integration(failures)
	_check_live_cpu_particles(failures)
	return failures


static func _check_resources(failures: Array[String]) -> void:
	for path in [CONTROLLER_PATH, SCENE_PATH, SHADER_PATH, SWAY_PATH]:
		if not ResourceLoader.exists(path):
			failures.append("Atmosphere resource missing: %s" % path)


static func _check_world_integration(failures: Array[String]) -> void:
	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("World scene should load for atmosphere acceptance")
		return

	var world := world_scene.instantiate()
	var atmosphere := world.get_node_or_null("Atmosphere")
	if atmosphere == null:
		failures.append("World should expose a presentation-only Atmosphere controller")
		world.free()
		return

	if not atmosphere.has_method("apply_time"):
		failures.append("Atmosphere should react to the existing time authority")
	if not atmosphere.has_method("apply_zone"):
		failures.append("Atmosphere should expose zone-specific visual profiles")
	if atmosphere.get_node_or_null("Overlay") == null:
		failures.append("Atmosphere should contain a screen-space overlay")
	if atmosphere.get_node_or_null("VegetationSway") == null:
		failures.append("Atmosphere should provide configurable vegetation sway")

	atmosphere.call("apply_time", 22, 0)
	var night_strength := float(atmosphere.get("night_strength"))
	atmosphere.call("apply_time", 12, 0)
	var day_strength := float(atmosphere.get("night_strength"))
	if night_strength <= day_strength:
		failures.append("Atmosphere should be visually stronger at night than at noon")

	atmosphere.call("apply_zone", &"cemetery")
	var cemetery_fog := float(atmosphere.get("fog_strength"))
	atmosphere.call("apply_zone", &"village_interior")
	var interior_fog := float(atmosphere.get("fog_strength"))
	var warmth := float(atmosphere.get("warmth"))
	if cemetery_fog <= interior_fog:
		failures.append("Cemetery should carry denser atmosphere than interiors")
	if warmth <= 0.5:
		failures.append("Interiors should use a clearly warmer atmosphere profile")

	world.free()


static func _check_live_cpu_particles(failures: Array[String]) -> void:
	var atmosphere_scene := load(SCENE_PATH) as PackedScene
	if atmosphere_scene == null:
		return
	var atmosphere := atmosphere_scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		failures.append("Atmosphere runtime test requires an active SceneTree")
		atmosphere.free()
		return

	tree.root.add_child(atmosphere)
	var motes := atmosphere.get_node_or_null("Motes") as CPUParticles2D
	if motes == null:
		failures.append("Atmosphere motes should remain CPUParticles2D")
		atmosphere.queue_free()
		return

	atmosphere.call("apply_zone", &"cemetery")
	var cemetery_amount := motes.amount
	atmosphere.call("apply_zone", &"village_interior")
	var interior_amount := motes.amount
	if cemetery_amount <= interior_amount:
		failures.append("CPU mote density should be higher in cemetery than warm interiors")
	if cemetery_amount < 1 or interior_amount < 1:
		failures.append("CPU mote amount should always remain a valid positive integer")
	atmosphere.queue_free()
