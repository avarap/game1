extends Node

var is_bootstrap_ready: bool = false


func mark_bootstrap_ready() -> void:
	if is_bootstrap_ready:
		return
	is_bootstrap_ready = true
	EventBus.bootstrap_ready.emit()
	GameLogger.info("GameManager marked bootstrap as ready")
