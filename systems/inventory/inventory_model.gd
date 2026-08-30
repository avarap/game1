class_name InventoryModel
extends RefCounted

var capacity_slots: int
var stacks: Array[InventoryStack] = []

func _init(p_capacity_slots: int = 20) -> void:
    capacity_slots = maxi(p_capacity_slots, 0)

func add_item(item: ItemData, amount: int) -> int:
    if item == null or not item.is_valid() or amount <= 0:
        return maxi(amount, 0)

    var remaining: int = amount

    for stack in stacks:
        if stack.item.id != item.id or stack.remaining_capacity() <= 0:
            continue
        var moved: int = mini(remaining, stack.remaining_capacity())
        stack.amount += moved
        remaining -= moved
        if remaining == 0:
            return 0

    while remaining > 0 and stacks.size() < capacity_slots:
        var stack_amount: int = mini(remaining, item.max_stack)
        stacks.append(InventoryStack.new(item, stack_amount))
        remaining -= stack_amount

    return remaining

func remove_item(item_id: StringName, amount: int) -> int:
    if item_id.is_empty() or amount <= 0:
        return 0

    var remaining: int = amount
    for index in range(stacks.size() - 1, -1, -1):
        var stack: InventoryStack = stacks[index]
        if stack.item.id != item_id:
            continue
        var removed: int = mini(remaining, stack.amount)
        stack.amount -= removed
        remaining -= removed
        if stack.is_empty():
            stacks.remove_at(index)
        if remaining == 0:
            break

    return amount - remaining

func count_item(item_id: StringName) -> int:
    var total: int = 0
    for stack in stacks:
        if stack.item.id == item_id:
            total += stack.amount
    return total

func has_item(item_id: StringName, amount: int = 1) -> bool:
    if amount <= 0:
        return true
    return count_item(item_id) >= amount

func free_slots() -> int:
    return maxi(capacity_slots - stacks.size(), 0)

func clear() -> void:
    stacks.clear()
