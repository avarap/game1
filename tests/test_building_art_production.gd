class_name TestBuildingArtProduction
extends RefCounted

const WORKSHOP_ATLAS := "res://art/environment/cemetery/production/atlas/"
const WORKSHOP_ART := WORKSHOP_ATLAS + "building_workshop_exterior.png"
const VILLAGE_HOUSE_ART := "res://art/environment/buildings/village_house.png"
const CEMETERY_MAP := "res://world/maps/cemetery/cemetery_map.tscn"
const VILLAGE_MAP := "res://world/maps/village/village_map.tscn"
const MIN_BUILDING_SIZE := Vector2i(288, 208)


static func run() -> Array[String]:
	var failures: Array[String] = []
	_validate_texture(WORKSHOP_ART, "Workshop", failures)
	_validate_texture(VILLAGE_HOUSE_ART, "Village house", failures)
	_validate_cemetery(failures)
	_validate_village(failures)
	return failures


static func _validate_texture(path: String, label: String, failures: Array[String]) -> void:
	if not ResourceLoader.exists(path):
		failures.append("%s production art should exist" % label)
		return
	var texture := load(path) as Texture2D
	if texture == null:
		failures.append("%s production art should load as Texture2D" % label)
		return
	var size := Vector2i(texture.get_width(), texture.get_height())
	if size.x < MIN_BUILDING_SIZE.x or size.y < MIN_BUILDING_SIZE.y:
		failures.append("%s production art should exceed placeholder scale" % label)


static func _validate_cemetery(failures: Array[String]) -> void:
	var map := _instantiate_map(CEMETERY_MAP, failures)
	if map == null:
		return
	var anchor := map.get_node_or_null("WorkshopArea/BuildingVisualAnchor") as Node2D
	if anchor == null:
		failures.append("Cemetery should expose a workshop visual anchor")
	elif anchor.get_node_or_null("ArtVisual") as Sprite2D == null:
		failures.append("Cemetery workshop anchor should receive production art")
	map.free()


static func _validate_village(failures: Array[String]) -> void:
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
		failures.append("Village buildings should keep distinct production identities")
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
