class_name NPCController
extends CharacterBody2D

signal destination_reached

@export var data: NPCData
@export var initial_target: Vector2 = Vector2.ZERO
@export var auto_start: bool = true

var navigation_started: bool = false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	if data == null:
		push_warning("NPCController requires NPCData")
		return
	if auto_start and initial_target != Vector2.ZERO:
		call_deferred("set_destination", initial_target)


func _physics_process(_delta: float) -> void:
	if data == null or not navigation_started:
		velocity = Vector2.ZERO
		return
	if navigation_agent.is_navigation_finished():
		_stop_navigation()
		return

	var next_position := navigation_agent.get_next_path_position()
	velocity = NPCNavigationMath.velocity_toward(global_position, next_position, data.move_speed)
	move_and_slide()


func set_destination(target: Vector2) -> void:
	navigation_agent.target_position = target
	navigation_started = true


func get_navigation_agent() -> NavigationAgent2D:
	return navigation_agent


func _stop_navigation() -> void:
	if not navigation_started:
		return
	navigation_started = false
	velocity = Vector2.ZERO
	destination_reached.emit()
