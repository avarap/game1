class_name CraftingStation
extends Interactable

@export var station_id: StringName = &"workbench"
@export var recipe: RecipeData

var last_result: StringName = &"idle"

func _on_interact(actor: Node) -> void:
    var inventory := actor.get_node_or_null("InventoryComponent") as InventoryComponent
    var energy := actor.get_node_or_null("EnergyComponent") as EnergyComponent
    if inventory == null or energy == null or recipe == null:
        _set_result(&"invalid_context")
        return
    if not energy.can_spend(recipe.energy_cost):
        _set_result(&"insufficient_energy")
        return

    inventory._ensure_model()
    var storage := _build_storage_network(actor, inventory)
    var result := CraftingService.craft_with_storage(recipe, station_id, storage)
    if result != CraftingService.RESULT_OK:
        _set_result(result)
        return

    energy.spend(recipe.energy_cost)
    inventory.inventory_changed.emit()
    _set_result(CraftingService.RESULT_OK)

func _build_storage_network(actor: Node, inventory: InventoryComponent) -> StorageNetwork:
    var storage := StorageNetwork.new()
    storage.add_provider(StorageProvider.new(&"player", inventory.model))

    var tree := get_tree()
    if tree == null:
        return storage

    for node in tree.get_nodes_in_group("storage_provider"):
        if node == actor or not node.has_method("get_storage_provider"):
            continue
        var provider := node.call("get_storage_provider") as StorageProvider
        if provider != null:
            storage.add_provider(provider)
    return storage

func _set_result(result: StringName) -> void:
    last_result = result
    var label := get_node_or_null("FeedbackLabel") as Label
    if label == null:
        return
    match result:
        CraftingService.RESULT_OK:
            label.text = "Fabricado: %s" % recipe.display_name
        CraftingService.RESULT_MISSING_INPUTS:
            label.text = "Faltan materiales"
        CraftingService.RESULT_INVENTORY_FULL:
            label.text = "Almacenamiento lleno"
        &"insufficient_energy":
            label.text = "Sin energía suficiente"
        _:
            label.text = "No se puede fabricar"
