extends PanelContainer

@onready var status: Label = $Margin/VBox/Status
@onready var advance_hour_button: Button = $Margin/VBox/AdvanceHour
@onready var save_button: Button = $Margin/VBox/Save

func _ready() -> void:
    visible = false
    advance_hour_button.pressed.connect(_on_advance_hour_pressed)
    save_button.pressed.connect(_on_save_pressed)
    EventBus.time_changed.connect(_refresh_status)
    EventBus.bootstrap_ready.connect(_refresh_status)
    _refresh_status()

func _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("debug_panel"):
        visible = not visible
        get_viewport().set_input_as_handled()

func _on_advance_hour_pressed() -> void:
    TimeManager.add_minutes(60)

func _on_save_pressed() -> void:
    SaveManager.save_game()
    _refresh_status()

func _refresh_status(_arg1 = null, _arg2 = null) -> void:
    status.text = "Bootstrap: %s\nDía %d — %02d:%02d\nFPS: %d" % [
        "OK" if GameManager.is_bootstrap_ready else "pendiente",
        TimeManager.day,
        TimeManager.hour,
        TimeManager.minute,
        Engine.get_frames_per_second()
    ]
