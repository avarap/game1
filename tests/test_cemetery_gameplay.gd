class_name TestCemeteryGameplay
extends RefCounted

static func run() -> Array[String]:
    var failures: Array[String] = []
    var world_scene := load("res://world/world.tscn") as PackedScene
    if world_scene == null:
        failures.append("World scene should load for cemetery gameplay acceptance")
        return failures

    var world := world_scene.instantiate()
    var controller := world.get_node_or_null("CemeteryController") as CemeteryController
    var delivery := world.get_node_or_null("CorpseDelivery") as CemeteryAction
    var preparation := world.get_node_or_null("PreparationTable") as CemeteryAction
    var grave_plot := world.get_node_or_null("GravePlot") as CemeteryAction
    var grave_upgrade := world.get_node_or_null("GraveUpgrade") as CemeteryAction

    if controller == null or delivery == null or preparation == null or grave_plot == null or grave_upgrade == null:
        failures.append("World should expose cemetery controller and all four interactables")
        world.free()
        return failures

    controller.initialize()
    delivery.interact(null)
    if delivery.last_result != CemeteryService.RESULT_OK or controller.service.pending_corpses.size() != 1:
        failures.append("Corpse delivery interactable should receive a corpse")

    preparation.interact(null)
    var pending_id := controller.service.first_pending_id()
    var pending := controller.service.pending_corpses.get(pending_id) as CorpseState
    if preparation.last_result != CemeteryService.RESULT_OK or pending == null or pending.current_preparation_level != 1:
        failures.append("Preparation table should prepare the first pending corpse")

    grave_plot.interact(null)
    if grave_plot.last_result != CemeteryService.RESULT_OK or controller.service.model.graves.size() != 1:
        failures.append("Grave plot should bury the prepared corpse")
    if controller.total_rating() != 2:
        failures.append("Burial should contribute base cemetery rating")

    grave_upgrade.interact(null)
    if grave_upgrade.last_result != CemeteryService.RESULT_OK or controller.total_rating() != 5:
        failures.append("First grave upgrade should install headstone")
    grave_upgrade.interact(null)
    if grave_upgrade.last_result != CemeteryService.RESULT_OK or controller.total_rating() != 7:
        failures.append("Second grave upgrade should install fence")
    grave_upgrade.interact(null)
    if grave_upgrade.last_result != CemeteryService.RESULT_OK or controller.total_rating() != 8:
        failures.append("Further grave upgrade should add decoration")

    var save_data := controller.get_save_data()
    var restored_controller := CemeteryController.new()
    restored_controller.rating_config = controller.rating_config
    restored_controller.apply_save_data(save_data)
    if restored_controller.total_rating() != 8 or restored_controller.service.model.graves.size() != 1:
        failures.append("Cemetery controller should restore its gameplay state")

    restored_controller.free()
    world.free()
    return failures
