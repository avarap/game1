class_name CemeteryMap
extends TechnicalMap


func _ready() -> void:
	# Visual layers and gameplay collision are authored directly in cemetery_map.tscn.
	_hide_technical_placeholders(self)


func _hide_technical_placeholders(node: Node) -> void:
	for child in node.get_children():
		if child is Polygon2D:
			(child as Polygon2D).visible = false
		elif child is Label and child.name == "FeedbackLabel":
			(child as Label).visible = false
		_hide_technical_placeholders(child)
