extends Node2D
## Presentation only: observes successful harvests; never changes loot or collision.

const WALK_SHEET := preload("res://world/maps/verdant_test/assets/player_walk.svg")
const DIRECTIONS := ["n", "ne", "e", "se", "s", "sw", "w", "nw"]

var _player: PlayerController
var _resource: ResourceNode
var _art: Sprite2D
var _stump: Texture2D
var _stump_pivot: Vector2
var _stump_scale: Vector2
var _depleted := false
var _message_time := 0.0
var _swing: Node2D
var _swing_tween: Tween
var _tree_tween: Tween
var _chips: CPUParticles2D


func setup(
	player: PlayerController,
	resource: ResourceNode,
	art: Sprite2D,
	stump: Texture2D,
	stump_pivot: Vector2,
	stump_scale: Vector2
) -> void:
	_player = player
	_resource = resource
	_art = art
	_stump = stump
	_stump_pivot = stump_pivot
	_stump_scale = stump_scale
	_install_walk_cycle()
	_build_axe()
	_chips = CPUParticles2D.new()
	_chips.name = "WoodChips"
	_chips.emitting = false
	_chips.one_shot = true
	_chips.amount = 10
	_chips.lifetime = 0.4
	_chips.explosiveness = 1.0
	_chips.direction = Vector2.UP
	_chips.spread = 65
	_chips.gravity = Vector2(0, 260)
	_chips.initial_velocity_min = 45
	_chips.initial_velocity_max = 85
	_chips.scale_amount_min = 2
	_chips.scale_amount_max = 3
	_chips.color = Color("c49c63")
	_chips.position = Vector2(0, -34)
	add_child(_chips)
	_resource.source.harvest_succeeded.connect(_on_hit)
	_resource.source.depleted.connect(_on_depleted)


func _process(delta: float) -> void:
	if _resource == null:
		return
	_message_time = maxf(0, _message_time - delta)
	var nearby := global_position.distance_to(_player.global_position) < 88
	_resource.feedback_label.visible = _message_time > 0 or (nearby and not _depleted)


func _install_walk_cycle() -> void:
	var body := _player.get_node("Body") as AnimatedSprite2D
	# Private resource: default player instances keep their original frames.
	var frames := body.sprite_frames.duplicate(true) as SpriteFrames
	for row in range(DIRECTIONS.size()):
		var animation := StringName("walk_" + DIRECTIONS[row])
		frames.clear(animation)
		frames.set_animation_speed(animation, 12)
		for phase in range(8):
			var texture := AtlasTexture.new()
			texture.atlas = WALK_SHEET
			texture.region = Rect2(phase * 64, row * 96, 64, 96)
			frames.add_frame(animation, texture)
	body.sprite_frames = frames


func _build_axe() -> void:
	_swing = Node2D.new()
	_swing.name = "HarvestSwing"
	_swing.z_index = 2
	_swing.hide()
	_player.add_child(_swing)
	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array(
		[Vector2(0, -2), Vector2(35, -2), Vector2(35, 2), Vector2(0, 2)]
	)
	handle.color = Color("b08550")
	_swing.add_child(handle)
	var head := Polygon2D.new()
	head.polygon = PackedVector2Array(
		[
			Vector2(27, -3),
			Vector2(29, -11),
			Vector2(38, -13),
			Vector2(42, -8),
			Vector2(39, 2),
			Vector2(30, 4),
		]
	)
	head.color = Color("c1c7b2")
	_swing.add_child(head)


func _on_hit(_item_id: StringName, _amount: int) -> void:
	_message_time = 1.2
	if _swing_tween != null:
		_swing_tween.kill()
	if _tree_tween != null:
		_tree_tween.kill()
	var direction := (_resource.global_position - _player.global_position).normalized()
	_swing.position = Vector2(0, -35) + direction * 8
	_swing.rotation = direction.angle() - 1.1
	_swing.show()
	_swing_tween = create_tween()
	_swing_tween.tween_property(_swing, "rotation", direction.angle() + 0.7, 0.13)
	_swing_tween.tween_interval(0.08)
	_swing_tween.tween_callback(_swing.hide)
	_art.rotation = -0.035
	_tree_tween = create_tween()
	_tree_tween.tween_property(_art, "rotation", 0.02, 0.09)
	_tree_tween.tween_property(_art, "rotation", 0.0, 0.12)
	_chips.restart()
	_chips.emitting = true


func _on_depleted() -> void:
	_depleted = true
	_message_time = 1.3
	if _tree_tween != null:
		_tree_tween.kill()
	_art.rotation = 0
	_art.texture = _stump
	_art.scale = _stump_scale
	_art.offset = -_stump_pivot / _stump_scale
