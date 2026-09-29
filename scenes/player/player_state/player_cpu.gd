@tool
class_name PlayerStateCPU
extends PlayerState

@export_group("Thinking")
@export var thinking_time := 1.75
@export_group("Difficulty")
@export var easy_difficulty_angle := 16.5
@export var medium_difficulty_angle := 11.5
@export var hard_difficulty_angle := 6.5

@export_group("Debug")
@export var override_weapon := false:
	set(value):
		override_weapon = value
		if not value:
			hitscan_only = false
			projectile_only = false
		notify_property_list_changed()
@export var hitscan_only := false
@export var projectile_only := false

var space_state: PhysicsDirectSpaceState2D

@onready var cpu_projectile_module: CPUProjectileModule = $CPUProjectileModule
@onready var cpu_hitscan_module: CPUHitscanModule = $CPUHitscanModule


func _validate_property(property: Dictionary) -> void:
	if property.name in ["hitscan_only", "projectile_only"]:
		property.usage = PROPERTY_USAGE_DEFAULT if override_weapon else PROPERTY_USAGE_NO_EDITOR


func enter(data := { }) -> void:
	EventSystem.busy.busy_started.emit(player)

	# Wait for game to be idle.
	await get_tree().process_frame
	space_state = player.get_world_2d().direct_space_state

	var reuse_weapon: bool = data.get("reuse", false)
	if reuse_weapon:
		if not await _try_weapon(player.equipped_item):
			player.finish()
		return

	# Prefer a direct hitscan shot, fall back to a projectile shot.
	var catalogue := GameManager.get_catalogue()
	if not projectile_only and await _try_weapon(_pick_unlocked(catalogue.get_hitscan_weapons())):
		return
	if not hitscan_only and await _try_weapon(_pick_unlocked(catalogue.get_projectile_weapons())):
		return

	player.finish()


func exit() -> void:
	cpu_hitscan_module.reset()
	cpu_projectile_module.reset()


## Finds a shot for the weapon, and if one exists equips it and shoots.
func _try_weapon(weapon: ItemResource) -> bool:
	if not weapon:
		return false

	var aimable := weapon.aimable_resource
	var shot: PlayerCPUWeaponModule.CPUShot
	if aimable is ProjectileWeaponResource:
		shot = await cpu_projectile_module.find_shot(aimable)
	elif aimable is HitscanWeaponResource:
		shot = cpu_hitscan_module.find_shot(aimable)

	if not shot:
		return false

	player.equip_item(weapon)
	await get_tree().create_timer(thinking_time, false).timeout

	# Most shots land near the aim, with occasional wild misses
	var angle := shot.angle + randfn(0.0, _get_angle_deviation())
	if shot is CPUProjectileModule.CPUProjectileShot:
		player.aimable_holder.cpu_shoot(angle, shot.force)
	else:
		player.aimable_holder.cpu_shoot(angle)
	return true


func _pick_unlocked(weapons: Array[ItemResource]) -> ItemResource:
	var locked_items := player.team.get_locked_items()
	var unlocked := weapons.filter(
		func(w: ItemResource) -> bool:
			return not locked_items.has(w),
	)
	return unlocked.pick_random()


func _get_angle_deviation() -> float:
	var difficulty := player.team.cpu_difficulty

	match difficulty:
		TeamResource.CPUDifficulty.MEDIUM:
			return deg_to_rad(medium_difficulty_angle)
		TeamResource.CPUDifficulty.HARD:
			return deg_to_rad(hard_difficulty_angle)
		_:
			return deg_to_rad(easy_difficulty_angle)
