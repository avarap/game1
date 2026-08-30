class_name CemeteryAction
extends Interactable

enum Action {
	RECEIVE,
	PREPARE,
	BURY,
	UPGRADE,
}

const RESULT_MISSING_CONTROLLER := &"missing_controller"

@export var controller: CemeteryController
@export var action: Action = Action.RECEIVE

var last_result: StringName = &""

func _on_interact(_actor: Node) -> void:
	var resolved_controller := _resolve_controller()
	if resolved_controller == null:
		last_result = RESULT_MISSING_CONTROLLER
		return

	match action:
		Action.RECEIVE:
			last_result = resolved_controller.receive_demo_corpse()
		Action.PREPARE:
			last_result = resolved_controller.prepare_first_pending()
		Action.BURY:
			last_result = resolved_controller.bury_first_pending()
		Action.UPGRADE:
			last_result = resolved_controller.upgrade_first_grave()

func _resolve_controller() -> CemeteryController:
	if controller != null:
		return controller
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group("cemetery_controller") as CemeteryController
