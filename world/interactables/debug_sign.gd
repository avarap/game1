class_name DebugSign
extends Interactable

@export var message: String = "El viejo sendero conduce al cementerio."

func _on_interact(_actor: Node) -> void:
    print("[INTERACT] %s" % message)
