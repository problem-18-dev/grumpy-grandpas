@abstract
class_name PlayerCPUWeaponModule
extends Node

const SHOT_SCORE_BASE := 1000

var sampled_shots: Array[Dictionary] = []

@onready var cpu: PlayerStateCPU = get_parent()


func _get_configuration_warnings() -> PackedStringArray:
	if cpu is not PlayerStateCPU:
		return ["Must be child of the player CPU state"]
	return []


@abstract func _get_aim_angles() -> Array[float]


@abstract func _determine_best_shot() -> Dictionary
