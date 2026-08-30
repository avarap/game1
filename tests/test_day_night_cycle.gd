class_name TestDayNightCycle
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_reference_colors(failures)
	_check_interpolation_and_phases(failures)
	_check_world_integration(failures)
	return failures


static func _check_reference_colors(failures: Array[String]) -> void:
	if not DayNightMath.color_at(6, 0).is_equal_approx(DayNightMath.DAWN_COLOR):
		failures.append("06:00 should match dawn color")
	if not DayNightMath.color_at(12, 0).is_equal_approx(DayNightMath.NOON_COLOR):
		failures.append("12:00 should match noon color")
	if not DayNightMath.color_at(18, 0).is_equal_approx(DayNightMath.DUSK_COLOR):
		failures.append("18:00 should match dusk color")
	if not DayNightMath.color_at(22, 0).is_equal_approx(DayNightMath.NIGHT_COLOR):
		failures.append("22:00 should match night color")


static func _check_interpolation_and_phases(failures: Array[String]) -> void:
	var morning := DayNightMath.color_at(9, 0)
	if morning.is_equal_approx(DayNightMath.DAWN_COLOR) or morning.is_equal_approx(DayNightMath.NOON_COLOR):
		failures.append("Morning color should interpolate between dawn and noon")

	var late_night := DayNightMath.color_at(2, 0)
	if late_night.is_equal_approx(DayNightMath.NIGHT_COLOR) or late_night.is_equal_approx(DayNightMath.DAWN_COLOR):
		failures.append("Late-night color should transition gradually toward dawn")

	if DayNightMath.phase_at(6, 0) != &"dawn":
		failures.append("06:00 should enter dawn phase")
	if DayNightMath.phase_at(12, 0) != &"day":
		failures.append("12:00 should enter day phase")
	if DayNightMath.phase_at(18, 0) != &"dusk":
		failures.append("18:00 should enter dusk phase")
	if DayNightMath.phase_at(22, 0) != &"night":
		failures.append("22:00 should enter night phase")


static func _check_world_integration(failures: Array[String]) -> void:
	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("World scene should load for day/night acceptance")
		return

	var world := world_scene.instantiate()
	var controller := world.get_node_or_null("DayNightCycle") as DayNightController
	if controller == null:
		failures.append("World should expose a local DayNightCycle controller")
		world.free()
		return

	controller.apply_time(12, 0)
	if not controller.color.is_equal_approx(DayNightMath.NOON_COLOR):
		failures.append("DayNightCycle should apply the calculated world modulation")
	if controller.current_phase != &"day":
		failures.append("DayNightCycle should expose the current visual phase")

	world.free()
