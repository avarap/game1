class_name TestCemeteryTraversal
extends RefCounted

const PLAYER_SCENE := preload("res://player/player.tscn")
const CEMETERY_MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const OPEN_SEGMENTS := [
	[Vector2(416, 800), Vector2(64, 0)],
	[Vector2(704, 704), Vector2(96, -64)],
	[Vector2(864, 640), Vector2(128, 0)],
	[Vector2(1344, 704), Vector2(128, 0)],
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	var packed := load(CEMETERY_MAP_PATH) as PackedScene
	if packed == null:
		failures.append("Cemetery traversal needs a loadable cemetery scene")
		return failures

	var map := packed.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)
	var player := PLAYER_SCENE.instantiate() as PlayerController
	map.add_child(player)
	player.set_physics_process(false)
	await tree.physics_frame
	await tree.physics_frame

	for segment in OPEN_SEGMENTS:
		player.position = segment[0]
		await tree.physics_frame
		var hit := player.move_and_collide(segment[1])
		if hit != null:
			failures.append("Real player should traverse authored corridor from %s" % segment[0])

	var collision := map.get_node("collision") as TileMapLayer
	var obstacle_center := collision.map_to_local(Vector2i(7, 20))
	player.position = obstacle_center + Vector2(0, 64)
	await tree.physics_frame
	var obstacle_hit := player.move_and_collide(Vector2(0, -96))
	if obstacle_hit == null:
		failures.append("Real player must collide with authored scenery footprints")

	map.free()
	return failures
