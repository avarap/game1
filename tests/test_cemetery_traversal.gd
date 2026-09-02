class_name TestCemeteryTraversal
extends RefCounted

const PLAYER_SCENE := preload("res://player/player.tscn")
const CEMETERY_SCENE := preload("res://world/maps/cemetery/cemetery_map.tscn")
const OPEN_SEGMENTS := [
	[Vector2(288, 704), Vector2(128, 0), "workshop apron"],
	[Vector2(1088, 576), Vector2(192, 0), "grave maintenance aisle"],
	[Vector2(1376, 736), Vector2(96, 64), "forest approach"],
	[Vector2(672, 160), Vector2(0, -64), "village approach"],
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var map := CEMETERY_SCENE.instantiate() as Node2D
	tree.root.add_child(map)

	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	map.add_child(player)
	player.set_physics_process(false)
	await tree.physics_frame
	await tree.physics_frame

	for segment in OPEN_SEGMENTS:
		player.position = segment[0]
		player.velocity = Vector2.ZERO
		await tree.physics_frame
		var hit := player.move_and_collide(segment[1], true)
		if hit != null:
			failures.append("Real player should traverse rebuilt %s without collision" % segment[2])

	var collision := map.get_node_or_null("collision") as TileMapLayer
	if collision == null:
		failures.append("Rebuilt cemetery traversal requires the collision layer")
	else:
		var blocker_center := collision.map_to_local(Vector2i(8, 17))
		player.position = blocker_center + Vector2(0, 64)
		player.velocity = Vector2.ZERO
		await tree.physics_frame
		var blocker_hit := player.move_and_collide(Vector2(0, -96), true)
		if blocker_hit == null:
			failures.append("Real player must collide with the rebuilt workshop footprint")

	player.free()
	map.free()
	return failures
