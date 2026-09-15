@tool
class_name PlayerStateCPU
extends PlayerState

@export_group("Projectile aiming")
@export var aim_attempts := 20
@export var aim_force_variations := 4
@export var aim_max_sampling_iterations := 5000
@export_group("Scoring")
@export var aim_min_score := 0.125
@export var enemy_reward_weight := 1.0
@export var teammate_penalty_weight := 1.0
@export_group("Thinking")
@export var thinking_time := 2.5

@export_group("Debug")
@export var override_weapon := false:
	set(value):
		override_weapon = value
		notify_property_list_changed()
@export var hitscan_only := false
@export var projectile_only := false

var space_state: PhysicsDirectSpaceState2D

@onready var cpu_projectile_module: CPUProjectileModule = $CPUProjectileModule
@onready var cpu_hitscan_module: CPUHitscanModule = $CPUHitscanModule


func enter(_data := { }) -> void:
	EventSystem.busy.busy_started.emit(player)

	var weapon := _get_random_weapon()
	player.equip_item(weapon)
	_find_shot(weapon.aimable_resource)


func exit() -> void:
	_reset()


func _validate_property(property: Dictionary) -> void:
	var validation_names := ["hitscan_only", "projectile_only"]
	if property.name in validation_names:
		property.usage = PROPERTY_USAGE_DEFAULT if override_weapon else PROPERTY_USAGE_NO_EDITOR

	if not override_weapon:
		hitscan_only = false
		projectile_only = false


func _find_shot(weapon: AimableResource) -> void:
	# Wait for game to be idle
	await get_tree().process_frame

	space_state = player.get_world_2d().direct_space_state

	var shot: PlayerCPUWeaponModule.CPUShot
	if weapon is ProjectileWeaponResource:
		shot = await cpu_projectile_module.find_shot(weapon)

	elif weapon is HitscanWeaponResource:
		shot = cpu_hitscan_module.find_shot(weapon)

	await get_tree().create_timer(thinking_time).timeout

	_handle_shot(shot)


func _get_random_weapon() -> ItemResource:
	var locked_items := player.team.get_locked_items()
	var catalogue := GameManager.get_catalogue()
	var available_items: Array[ItemResource] = catalogue.weapons.filter(
		func(weapon: ItemResource) -> bool:
			var is_unlocked := not locked_items.has(weapon)

			if not is_unlocked:
				return false

			if hitscan_only:
				return weapon.aimable_resource is HitscanWeaponResource

			if projectile_only:
				return weapon.aimable_resource is ProjectileWeaponResource

			return true,
	)

	return available_items.pick_random()


func _handle_shot(shot: PlayerCPUWeaponModule.CPUShot) -> void:
	if not shot:
		player.finish()
		return

	if shot is CPUProjectileModule.CPUProjectileShot:
		player.aimable_holder.cpu_shoot(shot.angle, shot.force)
		return

	player.aimable_holder.cpu_shoot(shot.angle)


func _reset() -> void:
	cpu_hitscan_module.reset()
	cpu_projectile_module.reset()
