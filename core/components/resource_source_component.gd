class_name ResourceSourceComponent
extends Node

signal harvest_succeeded(item_id: StringName, amount: int)
signal harvest_failed(reason: StringName)
signal depleted
signal feedback(message: String)

@export var loot_item: ItemData
@export_range(1, 99, 1) var loot_amount: int = 1
@export_range(1, 99, 1) var hit_points: int = 3
@export_range(0, 100, 1) var energy_cost: int = 4
@export var required_tool_id: StringName = &""

var remaining_hits: int

func _ready() -> void:
    remaining_hits = maxi(hit_points, 1)

func harvest(actor: Node) -> bool:
    if remaining_hits <= 0:
        return _fail(&"depleted", "El recurso está agotado.")
    if loot_item == null or loot_amount <= 0:
        return _fail(&"invalid_loot", "Este recurso no tiene loot configurado.")
    if actor == null:
        return _fail(&"invalid_actor", "No hay actor válido para recolectar.")
    if not _has_required_tool(actor):
        return _fail(&"missing_tool", "Necesitas la herramienta adecuada.")

    var inventory: InventoryComponent = actor.get_node_or_null("InventoryComponent") as InventoryComponent
    var energy: EnergyComponent = actor.get_node_or_null("EnergyComponent") as EnergyComponent
    if inventory == null:
        return _fail(&"missing_inventory", "No hay inventario disponible.")
    if energy == null:
        return _fail(&"missing_energy", "No hay energía disponible.")
    if not energy.can_spend(energy_cost):
        return _fail(&"insufficient_energy", "No tienes energía suficiente.")

    var remainder: int = inventory.add_item(loot_item, loot_amount)
    if remainder > 0:
        var accepted: int = loot_amount - remainder
        if accepted > 0:
            inventory.remove_item(loot_item.id, accepted)
        return _fail(&"inventory_full", "El inventario está lleno.")

    if not energy.spend(energy_cost):
        inventory.remove_item(loot_item.id, loot_amount)
        return _fail(&"insufficient_energy", "No tienes energía suficiente.")

    remaining_hits -= 1
    harvest_succeeded.emit(loot_item.id, loot_amount)
    feedback.emit("+%d %s · Energía -%d" % [loot_amount, loot_item.display_name, energy_cost])
    if remaining_hits <= 0:
        depleted.emit()
    return true

func _has_required_tool(actor: Node) -> bool:
    if required_tool_id == &"":
        return true
    if not actor.has_method("get_equipped_tool_id"):
        return false
    var tool_value: Variant = actor.call("get_equipped_tool_id")
    return StringName(tool_value) == required_tool_id

func _fail(reason: StringName, message: String) -> bool:
    harvest_failed.emit(reason)
    feedback.emit(message)
    return false
