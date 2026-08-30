class_name DialogueController
extends CanvasLayer

var service := DialogueService.new()

@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Margin/VBox/Speaker
@onready var body_label: Label = $DialoguePanel/Margin/VBox/Body
@onready var options_container: VBoxContainer = $DialoguePanel/Margin/VBox/Options
@onready var spanish_button: Button = $LanguageSelector/Spanish
@onready var english_button: Button = $LanguageSelector/English


func _enter_tree() -> void:
	add_to_group("dialogue_controller")


func _ready() -> void:
	dialogue_panel.hide()
	spanish_button.pressed.connect(_on_spanish_pressed)
	english_button.pressed.connect(_on_english_pressed)


func start_dialogue(dialogue: DialogueData, context: Dictionary = {}) -> bool:
	if not service.start(dialogue, context):
		dialogue_panel.hide()
		return false
	dialogue_panel.show()
	_render_current_node()
	return true


func select_option(option_id: StringName) -> bool:
	if not service.choose_option(option_id):
		return false
	if service.is_active():
		_render_current_node()
	else:
		dialogue_panel.hide()
	return true


func set_locale(locale: String) -> bool:
	if not LocalizationService.set_locale(locale):
		return false
	if service.is_active():
		_render_current_node()
	return true


func close_dialogue() -> void:
	service.clear()
	dialogue_panel.hide()


func is_dialogue_active() -> bool:
	return service.is_active() and dialogue_panel.visible


func get_current_body_text() -> String:
	return body_label.text


func get_current_speaker_text() -> String:
	return speaker_label.text


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready() and service.is_active():
		_render_current_node()


func _render_current_node() -> void:
	var node := service.current_node
	if node == null:
		dialogue_panel.hide()
		return

	speaker_label.text = LocalizationService.translate_key(node.speaker_name_key)
	body_label.text = LocalizationService.translate_key(node.text_key)
	_clear_options()

	var options := service.get_available_options()
	for option in options:
		var button := Button.new()
		button.text = LocalizationService.translate_key(option.text_key)
		button.pressed.connect(_on_option_pressed.bind(option.id))
		options_container.add_child(button)

	if options.is_empty():
		var button := Button.new()
		if node.next_node_id.is_empty():
			button.text = LocalizationService.translate_key(&"UI_DIALOGUE_CLOSE")
			button.pressed.connect(close_dialogue)
		else:
			button.text = LocalizationService.translate_key(&"UI_DIALOGUE_CONTINUE")
			button.pressed.connect(_on_continue_pressed)
		options_container.add_child(button)


func _clear_options() -> void:
	for child in options_container.get_children():
		options_container.remove_child(child)
		child.free()


func _on_option_pressed(option_id: StringName) -> void:
	select_option(option_id)


func _on_continue_pressed() -> void:
	if service.advance() and service.is_active():
		_render_current_node()
	else:
		dialogue_panel.hide()


func _on_spanish_pressed() -> void:
	set_locale("es")


func _on_english_pressed() -> void:
	set_locale("en")
