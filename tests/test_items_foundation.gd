class_name TestItemsFoundation
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []

	var item := load("res://data/items/wood.tres") as ItemData
	if item == null:
		failures.append("Phase 2 foundation should load wood ItemData resource")
	elif item.id != &"wood" or item.max_stack != 20:
		failures.append("Wood ItemData should expose configured data")

	var scene := load("res://player/player.tscn") as PackedScene
	if scene == null:
		failures.append("Player scene should remain loadable after inventory integration")
		return failures

	var player := scene.instantiate()
	var inventory := player.get_node_or_null("InventoryComponent")
	if inventory == null or not inventory is InventoryComponent:
		failures.append("Player should own a local InventoryComponent")
	else:
		inventory._ready()
		if inventory.model == null or inventory.model.capacity_slots != 20:
			failures.append("InventoryComponent should initialize its local model")

	player.free()
	return failures
