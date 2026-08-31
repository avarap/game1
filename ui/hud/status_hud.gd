class_name StatusHud
extends Control

var _energy_current := 0
var _energy_max := 1
var _context_key: StringName = &"UI_HUD_STATUS_READY"

@onready var energy_label: Label = $Panel/Margin/VBox/EnergyLabel
@onready var context_label: Label = $Panel/Margin/VBox/ContextLabel


func _ready() -> void:
	_refresh()


func set_energy(current: int, maximum: int) -> void:
	_energy_max = maxi(maximum, 1)
	_energy_current = clampi(current, 0, _energy_max)
	if is_node_ready():
		_refresh_energy()


func set_context_status(localization_key: StringName) -> void:
	_context_key = localization_key
	if is_node_ready():
		_refresh_context()


func get_energy_text() -> String:
	var label := LocalizationService.translate_key(&"UI_HUD_ENERGY")
	return "%s: %d / %d" % [label, _energy_current, _energy_max]


func get_context_text() -> String:
	return LocalizationService.translate_key(_context_key)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func _refresh() -> void:
	_refresh_energy()
	_refresh_context()


func _refresh_energy() -> void:
	energy_label.text = get_energy_text()


func _refresh_context() -> void:
	context_label.text = get_context_text()
