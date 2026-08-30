class_name ZoneTransition
extends Interactable

@export var target_position := Vector2.ZERO


func _on_interact(actor: Node) -> void:
	var actor_2d := actor as Node2D
	if actor_2d == null:
		return

	actor_2d.global_position = target_position
