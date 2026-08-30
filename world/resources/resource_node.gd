class_name ResourceNode
extends Interactable

@onready var source: ResourceSourceComponent = $ResourceSourceComponent
@onready var feedback_label: Label = $FeedbackLabel

func _ready() -> void:
    source.feedback.connect(_on_feedback)
    source.depleted.connect(_on_depleted)

func _on_interact(actor: Node) -> void:
    source.harvest(actor)

func _on_feedback(message: String) -> void:
    feedback_label.text = message

func _on_depleted() -> void:
    feedback_label.text = "Recurso agotado"
    monitoring = false
    monitorable = false
