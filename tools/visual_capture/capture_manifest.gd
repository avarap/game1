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


static func capture_specs() -> Array[Dictionary]:
	var specs: Array[Dictionary] = []
	for direction in DIRECTIONS:
		specs.append(_character_spec(&"player", PLAYER_SCENE, direction, Vector2(544, 640)))
	for direction in DIRECTIONS:
		specs.append(_character_spec(&"aldren", ALDREN_SCENE, direction, Vector2(1216, 640)))

	specs.append(
		_world_spec(
			&"cemetery_day",
			"cemetery_day.png",
			Vector2(960, 480),
			Color(1.0, 1.0, 1.0, 1.0)
		)
	)
	specs.append(
		_world_spec(
			&"cemetery_night",
			"cemetery_night.png",
			Vector2(960, 480),
			Color(0.42, 0.48, 0.62, 1.0)
		)
	)
	specs.append(
		_world_spec(
			&"cemetery_architecture_props",
			"cemetery_architecture_props.png",
			Vector2(480, 680),
			Color(0.92, 0.88, 0.82, 1.0)
		)
	)

	specs.append(
		_ui_spec(
			&"ui_inventory",
			"res://ui/inventory/inventory_panel.tscn",
			"ui_inventory.png",
			&"ready"
		)
	)
	specs.append(
		_ui_spec(
			&"ui_storage",
			"res://ui/storage/storage_panel.tscn",
			"ui_storage.png",
			&"empty"
		)
	)
	specs.append(
		_ui_spec(
			&"ui_crafting",
			"res://ui/crafting/crafting_panel.tscn",
			"ui_crafting.png",
			&"blocked"
		)
	)
	specs.append(
		_ui_spec(
			&"ui_trade",
			"res://ui/economy/trade_layer.tscn",
			"ui_trade.png",
			&"ready"
		)
	)
	return specs


static func _character_spec(
	actor: StringName, scene_path: String, direction: StringName, position: Vector2
) -> Dictionary:
	var capture_id := StringName("%s_%s" % [actor, direction])
	return {
		"id": capture_id,
		"kind": &"character",
		"actor": actor,
		"scene": scene_path,
		"context_scene": CEMETERY_SCENE,
		"direction": direction,
		"actor_position": position,
		"camera_position": position,
		"size": CAPTURE_SIZE,
		"camera_zoom": CAMERA_ZOOM,
		"lighting": Color(0.92, 0.88, 0.82, 1.0),
		"filename": "%s_%s.png" % [actor, direction],
	}


static func _world_spec(
	capture_id: StringName, filename: String, camera_position: Vector2, lighting: Color
) -> Dictionary:
	return {
		"id": capture_id,
		"kind": &"world",
		"scene": CEMETERY_SCENE,
		"camera_position": camera_position,
		"size": CAPTURE_SIZE,
		"camera_zoom": CAMERA_ZOOM,
		"lighting": lighting,
		"filename": filename,
	}


static func _ui_spec(
	capture_id: StringName, scene_path: String, filename: String, state: StringName
) -> Dictionary:
	return {
		"id": capture_id,
		"kind": &"ui",
		"scene": scene_path,
		"size": CAPTURE_SIZE,
		"camera_zoom": CAMERA_ZOOM,
		"ui_state": state,
		"filename": filename,
	}
