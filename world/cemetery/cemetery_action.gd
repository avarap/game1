class_name CemeteryAction
extends Interactable

enum Action {
    RECEIVE,
    PREPARE,
    BURY,
    UPGRADE,
}

const RESULT_MISSING_CONTROLLER := &"missing_controller"

@export var controller_path: NodePath = NodePath("../CemeteryController")
@export var action: Action = Action.RECEIVE

var last_result: StringName = &""

func _on_interact(_actor: Node) -> void:
    var controller := get_node_or_null(controller_path) as CemeteryController
    if controller == null:
        last_result = RESULT_MISSING_CONTROLLER
        return

    match action:
        Action.RECEIVE:
            last_result = controller.receive_demo_corpse()
        Action.PREPARE:
            last_result = controller.prepare_first_pending()
        Action.BURY:
            last_result = controller.bury_first_pending()
        Action.UPGRADE:
            last_result = controller.upgrade_first_grave()
