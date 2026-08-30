class_name ItemData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var category: StringName = &"resource"
@export_range(1, 999, 1) var max_stack: int = 99
@export_range(0, 999999, 1) var value: int = 0
@export var icon: Texture2D

func is_valid() -> bool:
    return not id.is_empty() and max_stack > 0
