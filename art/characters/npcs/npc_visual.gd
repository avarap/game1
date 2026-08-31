class_name NPCVisual
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

@export var default_facing: StringName = &"s"

var _facing: StringName


func _ready() -> void:
	_facing = default_facing
	_play_current(false)


func _process(_delta: float) -> void:
	var actor := get_parent() as CharacterBody2D
	if actor == null:
		return
	var moving := actor.velocity.length_squared() > MOVE_EPSILON
	if moving:
		_facing = _direction_name(actor.velocity)
	_play_current(moving)


func _play_current(moving: bool) -> void:
	var state := "walk" if moving else "idle"
	var target := StringName("%s_%s" % [state, _facing])
	if sprite_frames != null and sprite_frames.has_animation(target) and animation != target:
		play(target)


func _direction_name(value: Vector2) -> StringName:
	var angle := value.angle()
	var octant := int(round(angle / (PI / 4.0)))
	var direction_index := (octant + DIRECTION_NAMES.size()) % DIRECTION_NAMES.size()
	return DIRECTION_NAMES[direction_index]
