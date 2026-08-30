class_name StorageChest
extends Interactable

@export var provider_id: StringName = &"chest"
@export var storage_scope: StringName = &"workshop"


func get_inventory_component() -> InventoryComponent:
	return get_node_or_null("InventoryComponent") as InventoryComponent


func get_storage_provider() -> StorageProvider:
	var inventory := get_inventory_component()
	if inventory == null:
		return null
	inventory._ensure_model()
	return StorageProvider.new(provider_id, inventory.model, storage_scope)


func _on_interact(_actor: Node) -> void:
	var label := get_node_or_null("FeedbackLabel") as Label
	if label != null:
		label.text = "Cofre conectado"
