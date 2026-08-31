class_name CoreListPanel
extends PanelContainer

signal row_activated(index: int)

@export var title_key: StringName = &"UI_PANEL_INVENTORY_TITLE"

var selected_index := -1
var _rows: Array[Dictionary] = []
var _state: StringName = &"ready"

@onready var title_label: Label = $Margin/VBox/Title
@onready var state_label: Label = $Margin/VBox/State
@onready var rows_container: VBoxContainer = $Margin/VBox/Rows


func _ready() -> void:
	refresh_localization()


func set_rows(rows: Array) -> void:
	_rows.clear()
	for row in rows:
		if row is Dictionary:
			_rows.append(row)
	_rebuild_rows()
	set_state(&"empty" if _rows.is_empty() else &"ready")


func set_state(state: StringName) -> void:
	_state = state
	refresh_localization()


func select_row(index: int) -> void:
	selected_index = index if index >= 0 and index < _rows.size() else -1
	if selected_index >= 0 and selected_index < rows_container.get_child_count():
		var row_button := rows_container.get_child(selected_index) as Button
		if row_button != null:
			row_button.grab_focus()


func get_state_text() -> String:
	return state_label.text


func get_row_count() -> int:
	return _rows.size()


func refresh_localization() -> void:
	if not is_node_ready():
		return
	title_label.text = LocalizationService.translate_key(title_key)
	state_label.text = LocalizationService.translate_key(_state_key())
	state_label.visible = _state != &"ready"


func _state_key() -> StringName:
	match _state:
		&"empty":
			return &"UI_PANEL_STATE_EMPTY"
		&"blocked":
			return &"UI_PANEL_STATE_BLOCKED"
		&"error":
			return &"UI_PANEL_STATE_ERROR"
		_:
			return &"UI_PANEL_STATE_READY"


func _rebuild_rows() -> void:
	for child in rows_container.get_children():
		child.free()
	selected_index = -1
	for index in range(_rows.size()):
		var row := _rows[index]
		var button := Button.new()
		var title := str(row.get("title", ""))
		var detail := str(row.get("detail", ""))
		button.text = title if detail.is_empty() else "%s  ·  %s" % [title, detail]
		button.disabled = not bool(row.get("enabled", true))
		button.focus_mode = Control.FOCUS_ALL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_row_pressed.bind(index))
		rows_container.add_child(button)


func _on_row_pressed(index: int) -> void:
	select_row(index)
	row_activated.emit(index)
