class_name TradeInteractable
extends Interactable


func _on_interact(actor: Node) -> void:
	if not is_inside_tree():
		return
	var trade_panel := get_tree().get_first_node_in_group("trade_panel")
	var economy := get_tree().get_first_node_in_group("economy_controller")
	if trade_panel == null or economy == null:
		return
	if not trade_panel.has_method("open_trade"):
		return
	trade_panel.call("open_trade", actor, economy)
