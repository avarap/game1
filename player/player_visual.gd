class_name PlayerVisual
extends AnimatedSprite2D

const MOVE_EPSILON := 1.0
const DIRECTION_NAMES: Array[StringName] = [
	&"e",
	&"se",
	&"s",
	&"sw",
	&"w",
	&"nw",
	&"n",
	&"ne",
]

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
	var direction_index := (octant + DIRECTION_NAMES.size()) % DIRECTION_NAMES.size()
	return DIRECTION_NAMES[direction_index]
