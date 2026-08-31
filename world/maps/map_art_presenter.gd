class_name MapArtPresenter
extends RefCounted

const WORKBENCH := "res://art/environment/props/workbench.svg"
const STORAGE_CHEST := "res://art/environment/props/storage_chest.svg"
const BED := "res://art/environment/props/bed.svg"
const SIGN := "res://art/environment/props/sign.svg"
const PREPARATION_TABLE := "res://art/environment/cemetery/preparation_table.svg"
const GRAVE_FRESH := "res://art/environment/cemetery/grave_fresh.svg"
const GRAVE_WORN := "res://art/environment/cemetery/grave_worn.svg"
const PLAYER_WORKSHOP := "res://art/environment/buildings/player_workshop.svg"
const VILLAGE_HOUSE := "res://art/environment/buildings/village_house.svg"
const TREE := "res://art/environment/props/tree.svg"
const ROCK := "res://art/environment/props/rock.svg"
const WORKSHOP_PIVOT := Vector2(192, 248)
const VILLAGE_HOUSE_PIVOT := Vector2(176, 216)


static func apply(root: Node) -> void:
	_apply_path(root, "WorkshopArea/Workbench", WORKBENCH, Vector2(32, 42))
	_apply_path(root, "WorkshopArea/StorageChest", STORAGE_CHEST, Vector2(24, 34))
	_apply_path(root, "WorkshopArea/SleepSpot", BED, Vector2(32, 56))
	_apply_path(
		root,
		"WorkshopArea/BuildingVisualAnchor",
		PLAYER_WORKSHOP,
		WORKSHOP_PIVOT,
	)
	_apply_path(root, "CemeteryArea/CorpseDelivery", SIGN, Vector2(16, 42))
	_apply_path(root, "CemeteryArea/PreparationTable", PREPARATION_TABLE, Vector2(32, 42))
	_apply_path(root, "CemeteryArea/GravePlot", GRAVE_FRESH, Vector2(24, 38))
	_apply_path(root, "CemeteryArea/GraveUpgrade", GRAVE_WORN, Vector2(24, 38))
	_apply_path(root, "BuildingPlots/Workshop", PLAYER_WORKSHOP, WORKSHOP_PIVOT)
	_apply_path(root, "BuildingPlots/Inn", VILLAGE_HOUSE, VILLAGE_HOUSE_PIVOT)
	_apply_resources(root)


static func _apply_path(
	root: Node, node_path: String, texture_path: String, pivot: Vector2
) -> void:
	var target := root.get_node_or_null(node_path) as Node2D
	if target != null:
		_replace_placeholder(target, texture_path, pivot)


static func _apply_resources(root: Node) -> void:
	var resources := root.get_node_or_null("Resources")
	if resources == null:
		return
	var texture_path := TREE
	var pivot := Vector2(32, 84)
	if root.name == "MineMap":
		texture_path = ROCK
		pivot = Vector2(24, 34)
	for resource in resources.get_children():
		if resource is Node2D:
			_replace_placeholder(resource, texture_path, pivot)


static func _replace_placeholder(target: Node2D, texture_path: String, pivot: Vector2) -> void:
	var placeholder := target.get_node_or_null("Visual") as CanvasItem
	if placeholder != null:
		placeholder.visible = false
	var existing := target.get_node_or_null("ArtVisual") as Sprite2D
	if existing != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = "ArtVisual"
	sprite.texture = load(texture_path) as Texture2D
	sprite.centered = false
	sprite.position = -pivot
	target.add_child(sprite)
