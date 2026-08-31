class_name TestBuildingArtProduction
extends RefCounted

const WORKSHOP_ART := "res://art/environment/buildings/player_workshop.svg"
const VILLAGE_HOUSE_ART := "res://art/environment/buildings/village_house.svg"
const CEMETERY_MAP := "res://world/maps/cemetery/cemetery_map.tscn"
const VILLAGE_MAP := "res://world/maps/village/village_map.tscn"
const MIN_BUILDING_SIZE := Vector2i(288, 208)


static func run() -> Array[String]:
	var failures: Array[String] = []
	_validate_production_texture(WORKSHOP_ART, "Workshop", failures)
	_validate_production_texture(VILLAGE_HOUSE_ART, "Village house", failures)
	_validate_cemetery_integration(failures)
	_validate_village_integration(failures)
	return failures


static func _validate_production_texture(
	path: String, label: String, failures: Array[String]
) -> void:
	if not ResourceLoader.exists(path):
		failures.append("%s production art should exist" % label)
		return
	var texture := load(path) as Texture2D
	if texture == null:
		failures.append("%s production art should load as Texture2D" % label)
		return
	if (
		texture.get_width() < MIN_BUILDING_SIZE.x
		or texture.get_height() < MIN_BUILDING_SIZE.y
	):
		failures.append(
			"%s art should exceed placeholder scale (%dx%d minimum)"
			% [label, MIN_BUILDING_SIZE.x, MIN_BUILDING_SIZE.y]
		)


static func _validate_cemetery_integration(failures: Array[String]) -> void:
	var map := _instantiate_map(CEMETERY_MAP, failures)
	if map == null:
		return
	var anchor := map.get_node_or_null("WorkshopArea/BuildingVisualAnchor") as Node2D
	if anchor == null:
		failures.append("Cemetery should expose a dedicated workshop visual anchor")
	elif anchor.get_node_or_null("ArtVisual") as Sprite2D == null:
		failures.append("Cemetery workshop visual anchor should receive production art")
	map.free()


static func _validate_village_integration(failures: Array[String]) -> void:
	var map := _instantiate_map(VILLAGE_MAP, failures)
	if map == null:
		return
	var workshop := map.get_node_or_null("BuildingPlots/Workshop/ArtVisual") as Sprite2D
	var inn := map.get_node_or_null("BuildingPlots/Inn/ArtVisual") as Sprite2D
	if workshop == null:
		failures.append("Village workshop should receive production workshop art")
	if inn == null:
		failures.append("Village inn should receive production village-house art")
	if workshop != null and inn != null and workshop.texture == inn.texture:
		failures.append("Workshop and village house should keep distinct production identities")
	map.free()


static func _instantiate_map(path: String, failures: Array[String]) -> Node2D:
	var packed := load(path) as PackedScene
	if packed == null:
		failures.append("Building integration map should load: %s" % path)
		return null
	var map := packed.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)
	return map
