class_name PauseMenu
extends Control

signal resume_requested
signal audio_volume_requested(percent: int)
signal locale_requested(locale_code: StringName)

var _master_volume_percent := 100

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var volume_label: Label = $Panel/Margin/VBox/VolumeLabel
@onready var volume_slider: HSlider = $Panel/Margin/VBox/VolumeSlider
@onready var language_label: Label = $Panel/Margin/VBox/LanguageLabel
@onready var english_button: Button = $Panel/Margin/VBox/LanguageButtons/EnglishButton
@onready var spanish_button: Button = $Panel/Margin/VBox/LanguageButtons/SpanishButton
@onready var resume_button: Button = $Panel/Margin/VBox/ResumeButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	english_button.pressed.connect(_on_english_pressed)
	spanish_button.pressed.connect(_on_spanish_pressed)
	_refresh()
	resume_button.grab_focus()


func set_master_volume_percent(percent: int) -> void:
	_master_volume_percent = clampi(percent, 0, 100)
	if is_node_ready():
		volume_slider.set_value_no_signal(_master_volume_percent)
		_refresh_volume()


func get_master_volume_text() -> String:
	var label := LocalizationService.translate_key(&"UI_SETTINGS_MASTER_VOLUME")
	return "%s: %d%%" % [label, _master_volume_percent]


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func _refresh() -> void:
	title_label.text = LocalizationService.translate_key(&"UI_SETTINGS_TITLE")
	language_label.text = LocalizationService.translate_key(&"UI_SETTINGS_LANGUAGE")
	english_button.text = LocalizationService.translate_key(&"UI_SETTINGS_LANGUAGE_EN")
	spanish_button.text = LocalizationService.translate_key(&"UI_SETTINGS_LANGUAGE_ES")
	resume_button.text = LocalizationService.translate_key(&"UI_SETTINGS_RESUME")
	volume_slider.set_value_no_signal(_master_volume_percent)
	_refresh_volume()


func _refresh_volume() -> void:
	volume_label.text = get_master_volume_text()


func _on_resume_pressed() -> void:
	resume_requested.emit()


func _on_volume_changed(value: float) -> void:
	_master_volume_percent = clampi(roundi(value), 0, 100)
	_refresh_volume()
	audio_volume_requested.emit(_master_volume_percent)


func _on_english_pressed() -> void:
	locale_requested.emit(&"en")


func _on_spanish_pressed() -> void:
	locale_requested.emit(&"es")
