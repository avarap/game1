class_name Interactable
extends Area2D

signal interacted(actor: Node)

@export var prompt: String = "Interactuar"


func interact(actor: Node) -> void:
	interacted.emit(actor)
	_on_interact(actor)


func _on_interact(_actor: Node) -> void:
	pass
