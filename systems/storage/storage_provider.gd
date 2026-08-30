class_name StorageProvider
extends RefCounted

var provider_id: StringName
var inventory: InventoryModel

func _init(p_provider_id: StringName, p_inventory: InventoryModel) -> void:
    provider_id = p_provider_id
    inventory = p_inventory

func is_valid() -> bool:
    return not provider_id.is_empty() and inventory != null

func get_available_amount(item_id: StringName) -> int:
    if inventory == null:
        return 0
    return inventory.count_item(item_id)

func has_item(item_id: StringName, amount: int = 1) -> bool:
    if inventory == null:
        return amount <= 0
    return inventory.has_item(item_id, amount)

func consume(item_id: StringName, amount: int) -> int:
    if inventory == null:
        return 0
    return inventory.remove_item(item_id, amount)

func deposit(item: ItemData, amount: int) -> int:
    if inventory == null:
        return maxi(amount, 0)
    return inventory.add_item(item, amount)

func clone_provider() -> StorageProvider:
    var cloned_inventory := InventoryModel.new(inventory.capacity_slots if inventory != null else 0)
    if inventory != null:
        for stack in inventory.stacks:
            cloned_inventory.add_item(stack.item, stack.amount)
    return StorageProvider.new(provider_id, cloned_inventory)

func apply_from(source: StorageProvider) -> void:
    if inventory == null or source == null or source.inventory == null:
        return
    inventory.capacity_slots = source.inventory.capacity_slots
    inventory.clear()
    for stack in source.inventory.stacks:
        inventory.add_item(stack.item, stack.amount)
