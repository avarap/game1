class_name EnergyComponent
extends Node

signal energy_changed(current: int, maximum: int)
signal exhausted

@export_range(1, 1000, 1) var max_energy: int = 100
@export_range(0, 1000, 1) var current_energy: int = 100

func _ready() -> void:
    current_energy = clampi(current_energy, 0, max_energy)

func can_spend(cost: int) -> bool:
    return cost >= 0 and current_energy >= cost

func spend(cost: int) -> bool:
    if not can_spend(cost):
        exhausted.emit()
        return false
    current_energy -= cost
    energy_changed.emit(current_energy, max_energy)
    return true

func restore(amount: int) -> int:
    if amount <= 0:
        return 0
    var before: int = current_energy
    current_energy = mini(max_energy, current_energy + amount)
    var restored: int = current_energy - before
    if restored > 0:
        energy_changed.emit(current_energy, max_energy)
    return restored
