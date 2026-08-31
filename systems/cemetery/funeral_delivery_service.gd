class_name FuneralDeliveryService
extends RefCounted

const MINUTES_PER_DAY := 24 * 60
const DELIVERY_HOUR := 18
const DELIVERY_MINUTE := 0
const FODDER_ITEM_ID := &"fodder_turnip"
const ROADSIDE_DROPOFF := &"roadside_dropoff"
const RAMP_DROPOFF := &"ramp_dropoff"

var cemetery_service: CemeteryService
var storage: StorageNetwork
var fodder_cost: int = 1
var intro_delivered: bool = false
var last_resolved_day: int = 0
var next_corpse_serial: int = 1
var ramp_unlocked: bool = false
var reception_points: Dictionary = {}
var _has_observed_time: bool = false
var _last_observed_total_minutes: int = 0


func _init(
	p_cemetery_service: CemeteryService,
	p_storage: StorageNetwork,
	p_fodder_cost: int = 1,
) -> void:
	cemetery_service = p_cemetery_service
	storage = p_storage
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


func unlock_ramp() -> bool:
	if ramp_unlocked:
		return false
	ramp_unlocked = true
	return true


func is_ramp_unlocked() -> bool:
	return ramp_unlocked


func reception_point_for(corpse_id: StringName) -> StringName:
	return StringName(str(reception_points.get(corpse_id, "")))


func snapshot() -> Dictionary:
	var serialized_reception_points: Dictionary = {}
	for corpse_id in reception_points:
		serialized_reception_points[String(corpse_id)] = String(reception_points[corpse_id])
	return {
		"intro_delivered": intro_delivered,
		"last_resolved_day": last_resolved_day,
		"next_corpse_serial": next_corpse_serial,
		"ramp_unlocked": ramp_unlocked,
		"reception_points": serialized_reception_points,
		"has_observed_time": _has_observed_time,
		"last_observed_total_minutes": _last_observed_total_minutes,
	}


func apply_snapshot(data: Dictionary) -> void:
	intro_delivered = bool(data.get("intro_delivered", false))
	last_resolved_day = maxi(int(data.get("last_resolved_day", 0)), 0)
	next_corpse_serial = maxi(int(data.get("next_corpse_serial", 1)), 1)
	ramp_unlocked = bool(data.get("ramp_unlocked", false))
	reception_points.clear()
	var restored_points: Dictionary = data.get("reception_points", {})
	for corpse_id in restored_points:
		var point := StringName(str(restored_points[corpse_id]))
		if point == ROADSIDE_DROPOFF or point == RAMP_DROPOFF:
			reception_points[StringName(str(corpse_id))] = point
	_has_observed_time = bool(data.get("has_observed_time", false))
	_last_observed_total_minutes = maxi(int(data.get("last_observed_total_minutes", 0)), 0)


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
		var intro_corpse_id := _deliver_corpse(logical_day)
		if intro_corpse_id != &"":
			_emit_delivery_completed(intro_corpse_id, logical_day)
		return

	if storage == null or not storage.has_item(FODDER_ITEM_ID, fodder_cost):
		return

	var corpse_id := _deliver_corpse(logical_day)
	if corpse_id != &"":
		storage.consume(FODDER_ITEM_ID, fodder_cost)
		_emit_delivery_completed(corpse_id, logical_day)


func _deliver_corpse(logical_day: int) -> StringName:
	if cemetery_service == null:
		return &""

	var data := CorpseData.new()
	data.id = StringName("funeral_%04d_%04d" % [logical_day, next_corpse_serial])
	data.burial_value = 2
	var result := cemetery_service.receive_corpse(CorpseState.new(data))
	if result != CemeteryService.RESULT_OK:
		return &""

	reception_points[data.id] = RAMP_DROPOFF if ramp_unlocked else ROADSIDE_DROPOFF
	next_corpse_serial += 1
	return data.id


func _emit_delivery_completed(corpse_id: StringName, logical_day: int) -> void:
	var bus := _event_bus()
	if bus == null:
		return
	bus.emit_signal(
		"funeral_delivery_completed",
		corpse_id,
		logical_day,
		reception_point_for(corpse_id),
	)


func _event_bus() -> Node:
	var loop := Engine.get_main_loop()
	if loop == null:
		return null
	var tree := loop as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("EventBus")


func _delivery_total_minutes(logical_day: int) -> int:
	var day_offset := (maxi(logical_day, 1) - 1) * MINUTES_PER_DAY
	return day_offset + DELIVERY_HOUR * 60 + DELIVERY_MINUTE


func _to_total_minutes(day: int, hour: int, minute: int) -> int:
	var day_offset := (maxi(day, 1) - 1) * MINUTES_PER_DAY
	var hour_offset := clampi(hour, 0, 23) * 60
	return day_offset + hour_offset + clampi(minute, 0, 59)
