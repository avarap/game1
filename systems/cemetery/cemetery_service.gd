class_name CemeteryService
extends RefCounted

const RESULT_OK := &"ok"
const RESULT_INVALID_CORPSE := &"invalid_corpse"
const RESULT_DUPLICATE_CORPSE := &"duplicate_corpse"
const RESULT_NOT_FOUND := &"not_found"
const RESULT_ALREADY_OCCUPIED := &"already_occupied"
const RESULT_INVALID_GRAVE := &"invalid_grave"

var model: CemeteryModel
var pending_corpses: Dictionary = {}

func _init(cemetery_model: CemeteryModel) -> void:
    model = cemetery_model

func receive_corpse(corpse: CorpseState) -> StringName:
    if corpse == null or corpse.data == null or corpse.data.id == &"":
        return RESULT_INVALID_CORPSE
    if pending_corpses.has(corpse.data.id) or _find_grave_by_corpse_id(corpse.data.id) != null:
        return RESULT_DUPLICATE_CORPSE
    pending_corpses[corpse.data.id] = corpse
    return RESULT_OK

func prepare_corpse(corpse_id: StringName, amount: int = 1) -> StringName:
    var corpse := pending_corpses.get(corpse_id) as CorpseState
    if corpse == null:
        return RESULT_NOT_FOUND
    corpse.prepare(amount)
    return RESULT_OK

func bury_corpse(corpse_id: StringName) -> GraveRecord:
    var corpse := pending_corpses.get(corpse_id) as CorpseState
    if corpse == null or model == null:
        return null
    var grave := GraveRecord.new(corpse)
    model.add_grave(grave)
    pending_corpses.erase(corpse_id)
    return grave

func install_headstone(grave_index: int) -> StringName:
    var grave := _grave_at(grave_index)
    if grave == null:
        return RESULT_INVALID_GRAVE
    grave.has_headstone = true
    return RESULT_OK

func install_fence(grave_index: int) -> StringName:
    var grave := _grave_at(grave_index)
    if grave == null:
        return RESULT_INVALID_GRAVE
    grave.has_fence = true
    return RESULT_OK

func add_decoration(grave_index: int, amount: int = 1) -> StringName:
    var grave := _grave_at(grave_index)
    if grave == null:
        return RESULT_INVALID_GRAVE
    grave.decoration_count += maxi(amount, 0)
    return RESULT_OK

func total_rating() -> int:
    return model.total_rating() if model != null else 0

func snapshot() -> Dictionary:
    var pending: Array[Dictionary] = []
    for corpse_value in pending_corpses.values():
        var corpse := corpse_value as CorpseState
        if corpse != null:
            pending.append(corpse.snapshot())
    return {
        "pending_corpses": pending,
        "cemetery": model.snapshot() if model != null else {},
    }

func _grave_at(index: int) -> GraveRecord:
    if model == null or index < 0 or index >= model.graves.size():
        return null
    return model.graves[index]

func _find_grave_by_corpse_id(corpse_id: StringName) -> GraveRecord:
    if model == null:
        return null
    for grave in model.graves:
        if grave != null and grave.corpse != null and grave.corpse.data != null and grave.corpse.data.id == corpse_id:
            return grave
    return null
