class_name CemeteryModel
extends RefCounted

var rating_config: CemeteryRatingConfig
var graves: Array[GraveRecord] = []

func _init(config: CemeteryRatingConfig) -> void:
    rating_config = config

func add_grave(grave: GraveRecord) -> void:
    if grave != null:
        graves.append(grave)

func total_rating() -> int:
    var total: int = 0
    for grave in graves:
        total += grave.contribution(rating_config)
    return total

func snapshot() -> Dictionary:
    var serialized_graves: Array[Dictionary] = []
    for grave in graves:
        serialized_graves.append(grave.snapshot(rating_config))
    return {
        "rating": total_rating(),
        "graves": serialized_graves,
    }
