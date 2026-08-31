class_name WorldAtmosphereController
extends CanvasLayer

const MINUTES_PER_DAY := 24 * 60
const DAWN_START := 5 * 60
const DAY_START := 7 * 60
const DUSK_START := 18 * 60
const NIGHT_START := 20 * 60

@export var motes_enabled := true
@export_range(1, 256, 1) var base_mote_amount: int = 28

var night_strength: float = 0.0
var fog_strength: float = 0.68
var warmth: float = 0.18
var current_zone: StringName = &"cemetery"

var _elapsed: float = 0.0
var _event_bus: Node
var _time_manager: Node
var _zone_manager: Node

@onready var overlay: ColorRect = $Overlay
@onready var motes: CPUParticles2D = $Motes


func _enter_tree() -> void:
	_event_bus = get_node_or_null("/root/EventBus")
	_time_manager = get_node_or_null("/root/TimeManager")
	if _event_bus != null and _event_bus.has_signal("time_changed"):
		var callback := Callable(self, "_on_time_changed")
		if not _event_bus.is_connected("time_changed", callback):
			_event_bus.connect("time_changed", callback)


func _ready() -> void:
	_sync_time()
	_sync_zone()
	_apply_visual_state()


func _process(delta: float) -> void:
	_elapsed += delta
	_sync_zone()
	var shader_material := overlay.material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter("animation_time", _elapsed)


func apply_time(hour: int, minute: int) -> void:
	var total := posmod(hour * 60 + minute, MINUTES_PER_DAY)
	if total >= NIGHT_START or total < DAWN_START:
		night_strength = 1.0
	elif total >= DUSK_START:
		night_strength = inverse_lerp(float(DUSK_START), float(NIGHT_START), float(total))
	elif total < DAY_START:
		night_strength = 1.0 - inverse_lerp(float(DAWN_START), float(DAY_START), float(total))
	else:
		night_strength = 0.0
	_apply_visual_state()


func apply_zone(zone_id: StringName) -> void:
	current_zone = zone_id
	match zone_id:
		&"cemetery":
			fog_strength = 0.68
			warmth = 0.18
		&"forest":
			fog_strength = 0.50
			warmth = 0.24
		&"village":
			fog_strength = 0.27
			warmth = 0.52
		&"home_interior":
			fog_strength = 0.12
			warmth = 0.86
		&"village_interior":
			fog_strength = 0.14
			warmth = 0.82
		&"mine":
			fog_strength = 0.44
			warmth = 0.20
		_:
			fog_strength = 0.32
			warmth = 0.35
	_apply_visual_state()


func _on_time_changed(hour: int, minute: int) -> void:
	apply_time(hour, minute)


func _sync_time() -> void:
	if _time_manager == null:
		_time_manager = get_node_or_null("/root/TimeManager")
	if _time_manager != null:
		apply_time(int(_time_manager.get("hour")), int(_time_manager.get("minute")))


func _sync_zone() -> void:
	if _zone_manager == null:
		var managers := get_tree().get_nodes_in_group("zone_manager")
		if not managers.is_empty():
			_zone_manager = managers[0]
	if _zone_manager == null or not _zone_manager.has_method("get_active_zone_id"):
		return
	var zone_id := StringName(_zone_manager.call("get_active_zone_id"))
	if not zone_id.is_empty() and zone_id != current_zone:
		apply_zone(zone_id)


func _apply_visual_state() -> void:
	if not is_node_ready():
		return
	var shader_material := overlay.material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter("fog_strength", fog_strength)
		shader_material.set_shader_parameter("night_strength", night_strength)
		shader_material.set_shader_parameter("warmth", warmth)
		shader_material.set_shader_parameter("tint_color", _zone_tint())
	motes.emitting = motes_enabled
	var mote_density := clampf(fog_strength + night_strength * 0.15, 0.12, 1.0)
	motes.amount = maxi(1, roundi(float(base_mote_amount) * mote_density))
	motes.modulate = Color(0.72, 0.78, 0.78, 0.16 + night_strength * 0.10)


func _zone_tint() -> Color:
	match current_zone:
		&"cemetery":
			return Color("#66747a")
		&"forest":
			return Color("#66765f")
		&"village":
			return Color("#8a775e")
		&"home_interior", &"village_interior":
			return Color("#a27b53")
		&"mine":
			return Color("#5a6268")
		_:
			return Color("#707070")
