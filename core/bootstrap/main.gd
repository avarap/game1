extends Node2D


func _ready() -> void:
	GameLogger.info("Bootstrap scene ready")
	GameManager.mark_bootstrap_ready()
