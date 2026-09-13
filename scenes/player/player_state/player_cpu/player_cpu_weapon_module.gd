@abstract
class_name PlayerCPUWeaponModule
extends Node

@export_group("Debug")
@export var debug_pathing := false:
	set(value):
		if OS.is_debug_build():
			debug_pathing = value
			return
		debug_pathing = false

@onready var cpu: PlayerStateCPU = get_parent()


func _get_configuration_warnings() -> PackedStringArray:
	if cpu is not PlayerStateCPU:
		return ["Must be child of the player CPU state"]
	return []


@abstract func reset() -> void


func _add_debug_line() -> Line2D:
	var line := Line2D.new()
	line.width = 2
	line.default_color = Color(0.1, 0.4, 0.0, 1.0)
	add_child(line)
	return line
