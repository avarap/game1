class_name InventoryComponent
extends Node

signal inventory_changed
signal item_added(item_id: StringName, amount: int)
signal item_removed(item_id: StringName, amount: int)

@export_range(0, 200, 1) var capacity_slots: int = 20

var model: InventoryModel

func _ready() -> void:
    model = InventoryModel.new(capacity_slots)

func add_item(item: ItemData, amount: int) -> int:
    _ensure_model()
    var before := model.count_item(item.id) if item != null else 0
    var remainder := model.add_item(item, amount)
    var added := model.count_item(item.id) - before if item != null else 0
    if added > 0:
        item_added.emit(item.id, added)
        inventory_changed.emit()
    return remainder

func remove_item(item_id: StringName, amount: int) -> int:
    _ensure_model()
    var removed := model.remove_item(item_id, amount)
    if removed > 0:
        item_removed.emit(item_id, removed)
        inventory_changed.emit()
    return removed

func count_item(item_id: StringName) -> int:
    _ensure_model()
    return model.count_item(item_id)

func has_item(item_id: StringName, amount: int = 1) -> bool:
    _ensure_model()
    return model.has_item(item_id, amount)

func _ensure_model() -> void:
    if model == null:
        model = InventoryModel.new(capacity_slots)
