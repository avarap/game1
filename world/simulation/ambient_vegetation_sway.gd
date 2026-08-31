class_name AmbientVegetationSway
extends Node

const TREE_TEXTURE_PATH := "res://art/environment/props/tree.svg"

@export var enabled := true
@export_range(0.0, 2.0, 0.1) var sway_pixels := 1.0

var _elapsed := 0.0
var _scan_elapsed := 0.0
var _vegetation: Array[Sprite2D] = []


func _process(delta: float) -> void:
	_elapsed += delta
	_scan_elapsed += delta
	if _scan_elapsed >= 1.0 or _vegetation.is_empty():
		_scan_elapsed = 0.0
		_refresh_vegetation()
	for vegetation in _vegetation:
		if not is_instance_valid(vegetation):
			continue
		if not vegetation.has_meta("atmosphere_base_position"):
			vegetation.set_meta("atmosphere_base_position", vegetation.position)
		var base_position: Vector2 = vegetation.get_meta("atmosphere_base_position")
		if not enabled:
			vegetation.position = base_position
			continue
		var phase := float(vegetation.get_instance_id() % 997) * 0.017
		vegetation.position.x = base_position.x + sin(_elapsed * 0.75 + phase) * sway_pixels


func _refresh_vegetation() -> void:
	_vegetation.clear()
	_collect_vegetation(get_tree().current_scene)


func _collect_vegetation(node: Node) -> void:
	if node == null:
		return
	var sprite := node as Sprite2D
	if sprite != null and sprite.texture != null:
		if sprite.texture.resource_path == TREE_TEXTURE_PATH:
			_vegetation.append(sprite)
	for child in node.get_children():
		_collect_vegetation(child)
