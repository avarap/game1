class_name TestResourceLoop
extends RefCounted

static func run() -> Array[String]:
    var failures: Array[String] = []
    var player_scene := load("res://player/player.tscn") as PackedScene
    var tree_scene := load("res://world/resources/tree_resource.tscn") as PackedScene
    if player_scene == null or tree_scene == null:
        failures.append("Phase 2 resource loop scenes should load")
        return failures

    var player := player_scene.instantiate() as PlayerController
    var tree := tree_scene.instantiate() as ResourceNode
    var inventory := player.get_node("InventoryComponent") as InventoryComponent
    var energy := player.get_node("EnergyComponent") as EnergyComponent
    var source := tree.get_node("ResourceSourceComponent") as ResourceSourceComponent
    inventory._ready()
    energy._ready()
    source._ready()

    if not source.harvest(player):
        failures.append("Tree harvest should succeed with axe, inventory and energy")
    if inventory.count_item(&"wood") != 2:
        failures.append("Successful harvest should add configured wood loot")
    if energy.current_energy != 96:
        failures.append("Tree harvest should consume 4 energy")
    if source.remaining_hits != 2:
        failures.append("Successful harvest should reduce remaining resource hits")

    player.equipped_tool_id = &"pickaxe"
    var wood_before: int = inventory.count_item(&"wood")
    var energy_before: int = energy.current_energy
    if source.harvest(player):
        failures.append("Tree harvest should reject an invalid tool")
    if inventory.count_item(&"wood") != wood_before or energy.current_energy != energy_before:
        failures.append("Failed tool requirement must not mutate inventory or energy")

    player.equipped_tool_id = &"axe"
    energy.current_energy = 0
    if source.harvest(player):
        failures.append("Tree harvest should reject insufficient energy")
    if inventory.count_item(&"wood") != wood_before:
        failures.append("Insufficient energy must not grant loot")

    energy.current_energy = 100
    inventory.model = InventoryModel.new(0)
    if source.harvest(player):
        failures.append("Tree harvest should reject a full inventory")
    if energy.current_energy != 100:
        failures.append("Full inventory must not consume energy")

    tree.free()
    player.free()
    return failures
