class_name CemeteryArtCatalogData
extends Resource

@export var specs: Array[CemeteryVisualSpec] = []


func get_spec(spec_id: StringName) -> CemeteryVisualSpec:
	for spec in specs:
		if spec.id == spec_id:
			return spec
	return null
