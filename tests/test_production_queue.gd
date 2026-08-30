class_name TestProductionQueue
extends RefCounted

static func run() -> Array[String]:
    var failures: Array[String] = []
    var base_recipe := load("res://data/recipes/wood_to_plank.tres") as RecipeData
    var wood := load("res://data/items/wood.tres") as ItemData
    if base_recipe == null or wood == null:
        failures.append("Production queue test data should load")
        return failures

    var timed_recipe := base_recipe.duplicate(true) as RecipeData
    timed_recipe.duration_seconds = 2.0

    var inventory := InventoryModel.new(2)
    inventory.add_item(wood, 2)
    var network := StorageNetwork.new()
    network.add_provider(StorageProvider.new(&"player", inventory))
    var queue := ProductionQueue.new()

    var result := queue.enqueue(timed_recipe, &"workbench", network)
    if result != ProductionQueue.RESULT_QUEUED:
        failures.append("Timed recipe should enqueue when inputs are available")
    if inventory.count_item(&"wood") != 0 or inventory.count_item(&"plank") != 0:
        failures.append("Enqueue should reserve inputs without producing outputs immediately")

    result = queue.advance(1.0, network)
    if result != ProductionQueue.RESULT_PROCESSING:
        failures.append("Timed production should remain processing before duration elapses")
    var active := queue.current_job()
    if active == null or absf(active.progress_ratio() - 0.5) > 0.001:
        failures.append("Timed production should expose deterministic progress")

    result = queue.advance(1.0, network)
    if result != ProductionQueue.RESULT_COMPLETED or inventory.count_item(&"plank") != 1 or not queue.is_empty():
        failures.append("Timed production should deposit outputs and remove completed job")

    var missing_inventory := InventoryModel.new(1)
    var missing_network := StorageNetwork.new()
    missing_network.add_provider(StorageProvider.new(&"missing", missing_inventory))
    var missing_queue := ProductionQueue.new()
    result = missing_queue.enqueue(timed_recipe, &"workbench", missing_network)
    if result != ProductionQueue.RESULT_MISSING_INPUTS or missing_queue.size() != 0:
        failures.append("Queue should reject missing inputs without adding a job")

    var blocked_inventory := InventoryModel.new(1)
    blocked_inventory.add_item(wood, 2)
    var blocked_network := StorageNetwork.new()
    blocked_network.add_provider(StorageProvider.new(&"blocked", blocked_inventory))
    var blocked_queue := ProductionQueue.new()
    result = blocked_queue.enqueue(timed_recipe, &"workbench", blocked_network)
    blocked_inventory.add_item(wood, 1)
    result = blocked_queue.advance(2.0, blocked_network)
    if result != ProductionQueue.RESULT_OUTPUT_BLOCKED or blocked_queue.size() != 1:
        failures.append("Completed job should remain pending when output storage is full")
    blocked_inventory.remove_item(&"wood", 1)
    result = blocked_queue.advance(0.0, blocked_network)
    if result != ProductionQueue.RESULT_COMPLETED or blocked_inventory.count_item(&"plank") != 1:
        failures.append("Blocked output should complete after storage space becomes available")

    var player_scene := load("res://player/player.tscn") as PackedScene
    var station_scene := load("res://world/buildings/workbench.tscn") as PackedScene
    if player_scene == null or station_scene == null:
        failures.append("Player and workbench scenes should load for timed production integration")
        return failures

    var player := player_scene.instantiate() as PlayerController
    var station := station_scene.instantiate() as CraftingStation
    var actor_inventory := player.get_node("InventoryComponent") as InventoryComponent
    var energy := player.get_node("EnergyComponent") as EnergyComponent
    actor_inventory._ready()
    energy._ready()
    actor_inventory.add_item(wood, 2)
    station.recipe = timed_recipe
    station.interact(player)

    if station.last_result != ProductionQueue.RESULT_QUEUED:
        failures.append("Workbench should enqueue timed recipes")
    if energy.current_energy != 98:
        failures.append("Timed recipe should charge energy once when accepted")
    if actor_inventory.count_item(&"wood") != 0 or actor_inventory.count_item(&"plank") != 0:
        failures.append("Workbench timed recipe should reserve input and delay output")

    result = station.process_production(2.0)
    if result != ProductionQueue.RESULT_COMPLETED or actor_inventory.count_item(&"plank") != 1:
        failures.append("Workbench should complete queued production through StorageNetwork")

    station.free()
    player.free()
    return failures
