class_name QuestJournal
extends Control

signal close_requested

@export var quest_controller_path: NodePath

var _quest_controller: QuestController

@onready var title_label: Label = $Panel/Margin/VBox/Title
@onready var active_label: Label = $Panel/Margin/VBox/ActiveLabel
@onready var active_container: VBoxContainer = $Panel/Margin/VBox/ActiveQuests
@onready var completed_label: Label = $Panel/Margin/VBox/CompletedLabel
@onready var completed_container: VBoxContainer = $Panel/Margin/VBox/CompletedQuests
@onready var close_button: Button = $Panel/Margin/VBox/Close


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	_resolve_controller()
	refresh()


func set_quest_controller(controller: QuestController) -> void:
	_quest_controller = controller
	if is_node_ready():
		refresh()


func refresh() -> void:
	_refresh_static_labels()
	_clear_container(active_container)
	_clear_container(completed_container)
	if _quest_controller == null:
		_resolve_controller()
	if _quest_controller == null:
		return
	var sections := build_sections(_quest_controller.get_journal_entries())
	_render_section(active_container, sections.get("active", []))
	_render_section(completed_container, sections.get("completed", []))


func build_sections(entries: Array[Dictionary]) -> Dictionary:
	var active: Array[Dictionary] = []
	var completed: Array[Dictionary] = []
	for entry in entries:
		var display_entry := _build_display_entry(entry)
		match entry.get("status", QuestService.STATUS_UNAVAILABLE):
			QuestService.STATUS_ACTIVE:
				active.append(display_entry)
			QuestService.STATUS_COMPLETED:
				completed.append(display_entry)
	return {"active": active, "completed": completed}


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		refresh()


func _build_display_entry(entry: Dictionary) -> Dictionary:
	var title_key := StringName(str(entry.get("title_key", &"")))
	var description_key := StringName(str(entry.get("description_key", &"")))
	var objectives: Array = entry.get("objectives", [])
	return {
		"id": entry.get("id", &""),
		"status": entry.get("status", QuestService.STATUS_UNAVAILABLE),
		"title": LocalizationService.translate_key(title_key),
		"description": LocalizationService.translate_key(description_key),
		"objectives": objectives.duplicate(true),
	}


func _resolve_controller() -> void:
	if _quest_controller != null:
		return
	if not quest_controller_path.is_empty():
		_quest_controller = get_node_or_null(quest_controller_path) as QuestController
		if _quest_controller != null:
			return
	var node := get_tree().get_first_node_in_group("quest_controller")
	_quest_controller = node as QuestController


func _refresh_static_labels() -> void:
	title_label.text = LocalizationService.translate_key(&"UI_QUEST_JOURNAL_TITLE")
	active_label.text = LocalizationService.translate_key(&"UI_QUEST_JOURNAL_ACTIVE")
	completed_label.text = LocalizationService.translate_key(&"UI_QUEST_JOURNAL_COMPLETED")
	close_button.text = LocalizationService.translate_key(&"UI_QUEST_JOURNAL_CLOSE")


func _render_section(container: VBoxContainer, entries: Array) -> void:
	for entry_value in entries:
		var entry: Dictionary = entry_value
		var panel := PanelContainer.new()
		var content := VBoxContainer.new()
		var title := Label.new()
		var description := Label.new()
		title.text = str(entry.get("title", ""))
		description.text = str(entry.get("description", ""))
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(title)
		content.add_child(description)
		for objective_value in entry.get("objectives", []):
			var objective: Dictionary = objective_value
			var progress := Label.new()
			var progress_text := LocalizationService.translate_key(&"UI_QUEST_JOURNAL_PROGRESS")
			progress.text = "%s: %d/%d" % [
				progress_text,
				int(objective.get("current", 0)),
				int(objective.get("required", 0)),
			]
			content.add_child(progress)
		panel.add_child(content)
		container.add_child(panel)


func _clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.free()


func _on_close_pressed() -> void:
	close_requested.emit()
