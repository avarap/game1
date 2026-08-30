class_name RelationshipController
extends Node

@export var relationship_data: Array[RelationshipData] = []

var service := RelationshipService.new()


func _enter_tree() -> void:
	add_to_group("relationship_controller")


func _ready() -> void:
	for data in relationship_data:
		service.register(data)


func get_dialogue_context() -> Dictionary:
	return service.build_dialogue_context()


func get_relationship(id: StringName) -> int:
	return service.get_value(id)


func change_relationship(id: StringName, delta: int) -> bool:
	return service.change_value(id, delta)
