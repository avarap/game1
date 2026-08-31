class_name FuneralDeliveryService
extends RefCounted

const MINUTES_PER_DAY := 24 * 60
const DELIVERY_HOUR := 18
const DELIVERY_MINUTE := 0

var cemetery_service: CemeteryService
var fodder_cost: int = 1
var fodder_units: int = 0
var intro_delivered: bool = false
var last_resolved_day: int = 0
var next_corpse_serial: int = 1
var _has_observed_time: bool = false
var _last_observed_total_minutes: int = 0


func _init(p_cemetery_service: CemeteryService, p_fodder_cost: int = 1) -> void:
	cemetery_service = p_cemetery_service
	fodder_cost = maxi(p_fodder_cost, 1)


func sync_time(day: int, hour: int, minute: int = 0) -> void:
	var current_total := _to_total_minutes(day, hour, minute)
	if not _has_observed_time:
		_has_observed_time = true
		_last_observed_total_minutes = current_total
		return

	if current_total < _last_observed_total_minutes:
		_last_observed_total_minutes = current_total
		return

	_resolve_crossed_deliveries(_last_observed_total_minutes, current_total)
	_last_observed_total_minutes = current_total


func deposit_fodder(amount: int) -> void:
	fodder_units += maxi(amount, 0)


func fodder_count() -> int:
	return fodder_units


func snapshot() -> Dictionary:
	return {
		"fodder_units": fodder_units,
		"intro_delivered": intro_delivered,
		"last_resolved_day": last_resolved_day,
		"next_corpse_serial": next_corpse_serial,
		"has_observed_time": _has_observed_time,
		"last_observed_total_minutes": _last_observed_total_minutes,
	}


func apply_snapshot(data: Dictionary) -> void:
	fodder_units = maxi(int(data.get("fodder_units", 0)), 0)
	intro_delivered = bool(data.get("intro_delivered", false))
	last_resolved_day = maxi(int(data.get("last_resolved_day", 0)), 0)
	next_corpse_serial = maxi(int(data.get("next_corpse_serial", 1)), 1)
	_has_observed_time = bool(data.get("has_observed_time", false))
	_last_observed_total_minutes = maxi(
		int(data.get("last_observed_total_minutes", 0)), 0
	)


func _resolve_crossed_deliveries(previous_total: int, current_total: int) -> void:
	var first_day := int(previous_total / MINUTES_PER_DAY) + 1
	var last_day := int(current_total / MINUTES_PER_DAY) + 1
	for logical_day in range(first_day, last_day + 1):
		var threshold := _delivery_total_minutes(logical_day)
		if threshold > previous_total and threshold <= current_total:
			_resolve_day(logical_day)


func _resolve_day(logical_day: int) -> void:
	if logical_day <= last_resolved_day:
		return
	last_resolved_day = logical_day

	if not intro_delivered:
		intro_delivered = true
		_deliver_corpse(logical_day)
		return

	if fodder_units < fodder_cost:
		return

	if _deliver_corpse(logical_day):
		fodder_units -= fodder_cost


func _deliver_corpse(logical_day: int) -> bool:
	if cemetery_service == null:
		return false

	var data := CorpseData.new()
	data.id = StringName("funeral_%04d_%04d" % [logical_day, next_corpse_serial])
	data.burial_value = 2
	var result := cemetery_service.receive_corpse(CorpseState.new(data))
	if result != CemeteryService.RESULT_OK:
		return false

	next_corpse_serial += 1
	return true


func _delivery_total_minutes(logical_day: int) -> int:
	return (
		(maxi(logical_day, 1) - 1) * MINUTES_PER_DAY
		+ DELIVERY_HOUR * 60
		+ DELIVERY_MINUTE
	)


func _to_total_minutes(day: int, hour: int, minute: int) -> int:
	return (
		(maxi(day, 1) - 1) * MINUTES_PER_DAY
		+ clampi(hour, 0, 23) * 60
		+ clampi(minute, 0, 59)
	)
