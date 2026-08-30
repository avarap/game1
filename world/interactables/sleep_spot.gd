class_name SleepSpot
extends Interactable

@export var wake_hour: int = 6
@export var wake_minute: int = 0

func _on_interact(actor: Node) -> void:
    if actor == null:
        return

    var energy := actor.get_node_or_null("EnergyComponent") as EnergyComponent
    if energy == null:
        return

    var tree: SceneTree = null
    if is_inside_tree():
        tree = get_tree()
    else:
        tree = Engine.get_main_loop() as SceneTree
    if tree == null:
        return

    var time_manager := tree.root.get_node_or_null("TimeManager")
    if time_manager == null or not time_manager.has_method("advance_to_next_day"):
        return

    time_manager.call("advance_to_next_day", wake_hour, wake_minute)
    energy.restore(energy.max_energy)
