class_name CraftingStation
extends Interactable

@export var station_id: StringName = &"workbench"
@export var recipe: RecipeData

var last_result: StringName = &"idle"
var linked_storage_providers: Array[StorageProvider] = []
var production_queue: ProductionQueue = ProductionQueue.new()
var production_storage: StorageNetwork
var production_inventory_component: InventoryComponent

func register_storage_provider(provider: StorageProvider) -> void:
    if provider == null or not provider.is_valid():
        return
    linked_storage_providers.append(provider)

func clear_registered_storage_providers() -> void:
    linked_storage_providers.clear()

func _process(delta: float) -> void:
    if production_queue.is_empty() or production_storage == null:
        return
    process_production(delta)

func process_production(delta: float) -> StringName:
    if production_storage == null:
        return ProductionQueue.RESULT_IDLE
    var result := production_queue.advance(delta, production_storage)
    if result == ProductionQueue.RESULT_COMPLETED and production_inventory_component != null:
        production_inventory_component.inventory_changed.emit()
    if result != ProductionQueue.RESULT_PROCESSING:
        _set_result(result)
    return result

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

    if recipe.duration_seconds > 0.0:
        var queue_result := production_queue.enqueue(recipe, station_id, storage)
        if queue_result != ProductionQueue.RESULT_QUEUED:
            _set_result(queue_result)
            return
        energy.spend(recipe.energy_cost)
        production_storage = storage
        production_inventory_component = inventory
        inventory.inventory_changed.emit()
        _set_result(queue_result)
        return

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

    for provider in linked_storage_providers:
        storage.add_provider(provider)

    if not is_inside_tree():
        return storage

    for node in get_tree().get_nodes_in_group("storage_provider"):
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
        CraftingService.RESULT_INVENTORY_FULL, ProductionQueue.RESULT_OUTPUT_BLOCKED:
            label.text = "Almacenamiento lleno"
        ProductionQueue.RESULT_QUEUED:
            label.text = "En cola: %s" % recipe.display_name
        ProductionQueue.RESULT_COMPLETED:
            label.text = "Producción completada: %s" % recipe.display_name
        &"insufficient_energy":
            label.text = "Sin energía suficiente"
        _:
            label.text = "No se puede fabricar"
