class_name PlayerVisual
extends AnimatedSprite2D

const MOVE_EPSILON := 1.0
var _facing := &"s"

func _process(_delta: float) -> void:
	var actor := get_parent() as CharacterBody2D
	if actor == null:
		return
	var moving := actor.velocity.length_squared() > MOVE_EPSILON
	if moving:
		_facing = _direction_name(actor.velocity)
	var target := StringName("%s_%s" % ["walk" if moving else "idle", _facing])
	if animation != target:
		play(target)

func _direction_name(value: Vector2) -> StringName:
	var angle := value.angle()
	var octant := int(round(angle / (PI / 4.0)))
	match octant:
		-4, 4:
			return &"w"
		-3:
			return &"nw"
		-2:
			return &"n"
		-1:
			return &"ne"
		0:
			return &"e"
		1:
			return &"se"
		2:
			return &"s"
		3:
			return &"sw"
	return &"s"
