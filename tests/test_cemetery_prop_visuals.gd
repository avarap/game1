class_name TestCemeteryPropVisuals
extends RefCounted

const MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const WORKSHOP_PROP_ATLAS := (
	"res://art/environment/cemetery/production/atlas/"
	+ "cemetery_workshop_props_hand_authored_64.png"
)
const EXPECTED_PROP_ATLAS_SHA256 := (
	"16fb8d051c74ef241165aeb50b242169" + "94303ad9fc01aeb2f883792cc7fdfaae"
)


static func run() -> Array[String]:
	var failures: Array[String] = []
	_validate_workshop_prop_atlas(failures)
	var map := (load(MAP_PATH) as PackedScene).instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(map)
	for node_path in [
		"WorkshopArea/BuildingVisualAnchor",
		"WorkshopArea/Workbench",
		"WorkshopArea/StorageChest",
		"WorkshopArea/SleepSpot",
		"CemeteryArea/CorpseDelivery",
		"CemeteryArea/PreparationTable",
		"CemeteryArea/GravePlot",
		"CemeteryArea/GraveUpgrade",
	]:
		var visual := map.get_node_or_null(node_path + "/ArtVisual") as Sprite2D
		if visual == null or visual.texture == null:
			failures.append("Cemetery prop should use raster production art: %s" % node_path)
		elif visual.centered:
			failures.append("Cemetery prop should use an explicit base pivot: %s" % node_path)
	var workshop := map.get_node_or_null("WorkshopArea/BuildingVisualAnchor/ArtVisual") as Sprite2D
	if workshop != null and workshop.position != Vector2(-160, -240):
		failures.append("Workshop visual should keep its documented ground-contact pivot")
	for node_path in [
		"WorkshopArea/Workbench",
		"WorkshopArea/StorageChest",
		"WorkshopArea/SleepSpot",
		"CemeteryArea/PreparationTable",
	]:
		var visual := map.get_node(node_path + "/ArtVisual") as Sprite2D
		var atlas_texture := visual.texture as AtlasTexture
		if atlas_texture == null or atlas_texture.atlas.resource_path != WORKSHOP_PROP_ATLAS:
			failures.append("Workshop prop should use the authored prop sheet: %s" % node_path)
	map.free()
	return failures


static func _validate_workshop_prop_atlas(failures: Array[String]) -> void:
	if not FileAccess.file_exists(WORKSHOP_PROP_ATLAS):
		failures.append("Hand-authored cemetery workshop prop sheet should exist")
		return
	var texture := load(WORKSHOP_PROP_ATLAS) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != Vector2i(128, 128):
		failures.append("Workshop prop sheet should expose four 64px cells")
		return
	if FileAccess.get_sha256(WORKSHOP_PROP_ATLAS) != EXPECTED_PROP_ATLAS_SHA256:
		failures.append("Workshop prop pixels should match the reviewed authored baseline")
	for pixel_y in image.get_height():
		for pixel_x in image.get_width():
			var alpha := image.get_pixel(pixel_x, pixel_y).a
			if alpha != 0.0 and alpha != 1.0:
				failures.append("Workshop prop sheet should use hard pixel alpha")
				return
