class_name StorageChest
extends Interactable

@export var provider_id: StringName = &"chest"

func get_storage_provider() -> StorageProvider:
    var inventory := get_node_or_null("InventoryComponent") as InventoryComponent
    if inventory == null:
        return null
    inventory._ensure_model()
    return StorageProvider.new(provider_id, inventory.model)

func _on_interact(_actor: Node) -> void:
    var label := get_node_or_null("FeedbackLabel") as Label
    if label != null:
        label.text = "Cofre conectado"
