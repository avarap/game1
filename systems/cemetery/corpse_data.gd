class_name CorpseData
extends Resource

@export var id: StringName = &"corpse"
@export var quality: int = 0
@export_range(0.0, 1.0, 0.01) var decay: float = 0.0
@export var preparation_level: int = 0
@export var burial_value: int = 2
