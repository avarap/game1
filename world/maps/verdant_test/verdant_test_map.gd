extends Node2D
## Standalone visual experiment. Never registered with ZoneManager or save providers.

const CELL_SIZE := 32
const MAP_SIZE := Vector2i(30, 20)
const LOCAL_ASSET_DIRECTORY := "res://art/third_party/verdant_00"
const TERRAIN := preload("res://world/maps/verdant_test/verdant_terrain.gd")
const FEEDBACK := preload("res://world/maps/verdant_test/verdant_feedback.gd")
const FALLBACK_ATLAS := preload("res://world/maps/verdant_test/assets/terrain.svg")
const FALLBACK_TREES := [
	preload("res://world/maps/verdant_test/assets/tree_oak.svg"),
	preload("res://world/maps/verdant_test/assets/tree_pine.svg"),
	preload("res://world/maps/verdant_test/assets/tree_birch.svg"),
]
const TREE_PIVOTS := [Vector2(56, 132), Vector2(48, 148), Vector2(48, 132)]
const FALLBACK_STUMP := preload("res://world/maps/verdant_test/assets/stump.svg")
const UNDERGROWTH := preload("res://world/maps/verdant_test/assets/undergrowth.svg")
const FALLBACK_ROCK := preload("res://art/environment/props/rock.png")
const WORKSHOP := preload(
	"res://art/environment/cemetery/production/atlas/building_workshop_exterior.png"
)
const RESOURCE_TREE := preload("res://world/resources/tree_resource.tscn")

@export_dir var asset_directory: String = LOCAL_ASSET_DIRECTORY
@export var use_local_assets := true

var uses_verdant_assets := false
var _local_images: Dictionary = {}
var _path_cells: Dictionary = {}

@onready var ground: TileMapLayer = $Ground
@onready var paths: TileMapLayer = $Paths
@onready var objects: Node2D = $Objects
@onready var player: PlayerController = $Objects/Player


func _ready() -> void:
	uses_verdant_assets = _local_image("grass_0", Vector2i(16, 16)) != null
	_build_terrain()
	_build_objects()
	_build_boundary()
	player.position = $PlayerSpawn.position
	var camera := player.get_node("Camera2D") as Camera2D
	camera.limit_right = MAP_SIZE.x * CELL_SIZE
	camera.limit_bottom = MAP_SIZE.y * CELL_SIZE
	camera.reset_smoothing()
	var energy := player.get_energy_component()
	energy.energy_changed.connect($UI/StatusHud.set_energy)
	$UI/StatusHud.set_energy(energy.current_energy, energy.max_energy)
	$UI/Mode.text = (
		"VERDANT 00 · LOCAL PNGs" if uses_verdant_assets else "VERDANT TEST · FALLBACK"
	)


func _local_image(role: String, expected_size: Vector2i) -> Image:
	if not use_local_assets:
		return null
	if _local_images.has(role):
		return _local_images[role] as Image
	_local_images[role] = null
	var path := asset_directory.path_join(role + ".png")
	if not FileAccess.file_exists(path):
		return null
	var bytes := FileAccess.get_file_as_bytes(path)
	# Do not ask ResourceLoader to resolve an optional import or a missing dependency.
	if bytes.size() < 24 or bytes.slice(0, 8) != PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]):
		return null
	var image := Image.new()
	if image.load_png_from_buffer(bytes) != OK or image.get_size() != expected_size:
		return null
	image.convert(Image.FORMAT_RGBA8)
	_local_images[role] = image
	return image


func _fill_image(material: String, variant: int) -> Image:
	if uses_verdant_assets:
		var local := _local_image("%s_%d" % [material, variant], Vector2i(16, 16))
		if local == null:
			local = _local_image(material + "_0", Vector2i(16, 16))
		if local != null:
			var enlarged := local.duplicate() as Image
			enlarged.resize(CELL_SIZE, CELL_SIZE, Image.INTERPOLATE_NEAREST)
			return enlarged
	var column := variant + (4 if material == "dirt" else 0)
	return FALLBACK_ATLAS.get_image().get_region(Rect2i(column * CELL_SIZE, 0, 32, 32))


func _build_terrain() -> void:
	var grass: Array[Image] = []
	var dirt: Array[Image] = []
	for variant in range(4):
		grass.append(_fill_image("grass", variant))
		dirt.append(_fill_image("dirt", variant))
	TERRAIN.populate(ground, paths, grass, dirt)
	for cell in paths.get_used_cells():
		_path_cells[cell] = true


func _build_objects() -> void:
	var trees: Array[Vector2i] = [Vector2i(4, 6), Vector2i(11, 6), Vector2i(25, 7)]
	for x in range(2, 29, 2):
		trees.append(Vector2i(x, 2 + x % 3))
		trees.append(Vector2i(x, 16 + (x / 2) % 3))
	for index in range(trees.size()):
		var tree := _obstacle("Tree%d" % index, _cell_center(trees[index]), Vector2(18, 16))
		var species := index % FALLBACK_TREES.size()
		_add_prop(tree, "tree", FALLBACK_TREES[species], TREE_PIVOTS[species], Vector2i(32, 32))
	var rocks := [Vector2i(13, 8), Vector2i(27, 8), Vector2i(3, 15), Vector2i(21, 16)]
	for index in range(rocks.size()):
		var rock := _obstacle("Rock%d" % index, _cell_center(rocks[index]), Vector2(24, 16))
		_add_prop(rock, "rock", FALLBACK_ROCK, Vector2(24, 34), Vector2i(16, 16))
	var workshop := _obstacle("Workshop", Vector2(624, 272), Vector2(272, 128))
	var building := Sprite2D.new()
	building.texture = WORKSHOP
	building.centered = false
	building.position = -Vector2(192, 248)
	workshop.add_child(building)
	_build_harvest_tree()
	_build_decoration()


func _obstacle(node_name: String, foot: Vector2, footprint: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = node_name
	body.position = foot
	body.collision_layer = 1
	body.collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = footprint
	collision.shape = shape
	collision.position.y = -footprint.y * 0.5
	body.add_child(collision)
	objects.add_child(body)
	return body


func _add_prop(
	parent: Node2D, role: String, fallback: Texture2D, pivot: Vector2, source_size: Vector2i
) -> void:
	var sprite := Sprite2D.new()
	sprite.name = "Art"
	sprite.centered = false
	var local: Image = _local_image(role, source_size) if uses_verdant_assets else null
	if local != null:
		sprite.texture = ImageTexture.create_from_image(local)
		var magnification := 4 if role == "tree" else 2
		sprite.scale = Vector2.ONE * magnification
		sprite.offset = -Vector2(source_size.x * 0.5, source_size.y - 2)
	else:
		sprite.texture = fallback
		sprite.offset = -pivot
	parent.add_child(sprite)


func _build_harvest_tree() -> void:
	var trunk := _obstacle("HarvestTree", Vector2(272, 272), Vector2(18, 16))
	_add_prop(trunk, "tree", FALLBACK_TREES[0], TREE_PIVOTS[0], Vector2i(32, 32))
	var resource := RESOURCE_TREE.instantiate() as ResourceNode
	resource.name = "Resource"
	resource.get_node("Trunk").hide()
	resource.get_node("Crown").hide()
	trunk.add_child(resource)
	var stump: Texture2D = FALLBACK_STUMP
	var pivot := Vector2(24, 32)
	var magnification := Vector2.ONE
	var local := _local_image("stump", Vector2i(16, 16)) if uses_verdant_assets else null
	if local != null:
		stump = ImageTexture.create_from_image(local)
		pivot = Vector2(16, 28)
		magnification = Vector2(2, 2)
	var feedback := FEEDBACK.new()
	feedback.name = "HarvestFeedback"
	trunk.add_child(feedback)
	feedback.setup(player, resource, trunk.get_node("Art"), stump, pivot, magnification)


func _build_decoration() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 730021
	var clusters := [
		Vector2(80, 150),
		Vector2(358, 202),
		Vector2(875, 190),
		Vector2(106, 515),
		Vector2(362, 565),
		Vector2(755, 572),
		Vector2(874, 592),
		Vector2(425, 292),
	]
	for index in range(120):
		var foot: Vector2 = clusters[index % clusters.size()]
		foot += Vector2(rng.randf_range(-46, 46), rng.randf_range(-30, 30))
		var cell := Vector2i(foot / CELL_SIZE)
		if _path_cells.has(cell) or Rect2i(14, 3, 10, 6).has_point(cell):
			continue
		var anchor := Node2D.new()
		anchor.position = foot
		$DecorationLow.add_child(anchor)
		var texture := AtlasTexture.new()
		texture.atlas = UNDERGROWTH
		var variant := 2 if index % 7 == 0 else index % 2
		texture.region = Rect2(variant * 32, 0, 32, 32)
		_add_prop(
			anchor,
			"flowers" if variant == 2 else "bush",
			texture,
			Vector2(16, 28),
			Vector2i(16, 16)
		)


func _build_boundary() -> void:
	for rect in [
		Rect2(-32, -32, 1024, 32),
		Rect2(-32, 640, 1024, 32),
		Rect2(-32, 0, 32, 640),
		Rect2(960, 0, 32, 640),
	]:
		var body := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		body.position = rect.get_center()
		body.add_child(collision)
		$Boundary.add_child(body)


func _cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE) + Vector2(16, 16)
