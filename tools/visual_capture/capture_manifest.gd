class_name VisualCaptureManifest
extends RefCounted

const CAPTURE_SIZE := Vector2i(1280, 720)
const CAMERA_ZOOM := Vector2(1.5, 1.5)
const CEMETERY_SCENE := "res://world/maps/cemetery/cemetery_map.tscn"
const PLAYER_SCENE := "res://player/player.tscn"
const ALDREN_SCENE := "res://world/npcs/brother_aldren.tscn"
const DIRECTIONS: Array[StringName] = [
	&"n",
	&"ne",
	&"e",
	&"se",
	&"s",
	&"sw",
	&"w",
	&"nw",
]
const WORLD_IDS: Array[StringName] = [
	&"cemetery_day",
	&"cemetery_night",
	&"cemetery_architecture_props",
]
const UI_SCENES := {
	&"ui_inventory": "res://ui/inventory/inventory_panel.tscn",
	&"ui_storage": "res://ui/storage/storage_panel.tscn",
	&"ui_crafting": "res://ui/crafting/crafting_panel.tscn",
	&"ui_trade": "res://ui/economy/trade_layer.tscn",
}
const UI_STATES := {
	&"ui_inventory": &"ready",
	&"ui_storage": &"empty",
	&"ui_crafting": &"blocked",
	&"ui_trade": &"ready",
}


static func capture_specs() -> Array[Dictionary]:
	var specs: Array[Dictionary] = []
	for direction in DIRECTIONS:
		specs.append(_character_spec(&"player", direction))
	for direction in DIRECTIONS:
		specs.append(_character_spec(&"aldren", direction))
	for capture_id in WORLD_IDS:
		specs.append(_world_spec(capture_id))
	for capture_id in UI_SCENES:
		specs.append(_ui_spec(capture_id))
	return specs


static func _character_spec(actor: StringName, direction: StringName) -> Dictionary:
	var capture_id := StringName("%s_%s" % [actor, direction])
	var is_player := actor == &"player"
	var position := Vector2(544, 640) if is_player else Vector2(1216, 640)
	return {
		"id": capture_id,
		"kind": &"character",
		"actor": actor,
		"scene": PLAYER_SCENE if is_player else ALDREN_SCENE,
		"context_scene": CEMETERY_SCENE,
		"direction": direction,
		"actor_position": position,
		"camera_position": position,
		"size": CAPTURE_SIZE,
		"camera_zoom": CAMERA_ZOOM,
		"lighting": Color(0.92, 0.88, 0.82, 1.0),
		"filename": "%s.png" % capture_id,
	}


static func _world_spec(capture_id: StringName) -> Dictionary:
	var camera_position := Vector2(960, 480)
	var lighting := Color.WHITE
	if capture_id == &"cemetery_night":
		lighting = Color(0.42, 0.48, 0.62, 1.0)
	elif capture_id == &"cemetery_architecture_props":
		camera_position = Vector2(480, 680)
		lighting = Color(0.92, 0.88, 0.82, 1.0)
	return {
		"id": capture_id,
		"kind": &"world",
		"scene": CEMETERY_SCENE,
		"camera_position": camera_position,
		"size": CAPTURE_SIZE,
		"camera_zoom": CAMERA_ZOOM,
		"lighting": lighting,
		"filename": "%s.png" % capture_id,
	}


static func _ui_spec(capture_id: StringName) -> Dictionary:
	return {
		"id": capture_id,
		"kind": &"ui",
		"scene": str(UI_SCENES[capture_id]),
		"size": CAPTURE_SIZE,
		"camera_zoom": CAMERA_ZOOM,
		"ui_state": StringName(UI_STATES[capture_id]),
		"filename": "%s.png" % capture_id,
	}
