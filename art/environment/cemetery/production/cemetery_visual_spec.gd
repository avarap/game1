class_name CemeteryVisualSpec
extends Resource

@export var id: StringName
@export var texture: Texture2D
@export var region := Rect2i()
@export var pivot_px := Vector2i()
@export var footprint_px := Vector2i()
@export_enum("low", "y_sorted", "foreground") var layer_role := "y_sorted"
