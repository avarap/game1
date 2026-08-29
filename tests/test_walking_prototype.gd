class_name TestWalkingPrototype
extends RefCounted

static func run() -> Array[String]:
    var failures: Array[String] = []

    var player_scene := load("res://player/player.tscn") as PackedScene
    if player_scene == null:
        failures.append("Walking prototype should load player/player.tscn")
        return failures

    var player := player_scene.instantiate()
    if not player is CharacterBody2D:
        failures.append("Player scene root should be CharacterBody2D")
    else:
        var interaction_area := player.get_node_or_null("InteractionArea")
        if not interaction_area is Area2D:
            failures.append("Player should expose an InteractionArea")

        var camera := player.get_node_or_null("Camera2D") as Camera2D
        if camera == null:
            failures.append("Player should include a Camera2D")
        else:
            if not camera.position_smoothing_enabled:
                failures.append("Camera2D smoothing should be enabled")
            if camera.limit_right <= camera.limit_left or camera.limit_bottom <= camera.limit_top:
                failures.append("Camera2D should have valid map limits")

    player.free()

    var world_scene := load("res://world/world.tscn") as PackedScene
    if world_scene == null:
        failures.append("Walking prototype should load world/world.tscn")
        return failures

    var world := world_scene.instantiate()
    if not world.y_sort_enabled:
        failures.append("World should have Y-sort enabled")

    var world_player := world.get_node_or_null("Player")
    if not world_player is CharacterBody2D:
        failures.append("World should instance the player")

    var boundaries := world.get_node_or_null("Boundaries")
    if boundaries == null or boundaries.get_child_count() < 4:
        failures.append("World should provide collision boundaries")

    var debug_sign := world.get_node_or_null("DebugSign")
    if not debug_sign is Interactable:
        failures.append("World should provide at least one functional Interactable")

    world.free()
    return failures
