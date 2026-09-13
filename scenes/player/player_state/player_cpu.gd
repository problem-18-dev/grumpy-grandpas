@tool
class_name PlayerStateCPU
extends PlayerState

@export_group("Aiming")
@export var aim_attempts := 20
@export_group("Timing")
@export var calculation_time := 3.0
@export var aim_time := 3.0
@export_group("Debug")
@export var override_weapon := false:
	set(value):
		override_weapon = value
		notify_property_list_changed()
@export var hitscan_only := false
@export var projectile_only := false

var teammates: Array[Node]
var enemies: Array[Node]
var space_state: PhysicsDirectSpaceState2D

@onready var cpu_projectile_module: CPUProjectileModule = $CPUProjectileModule
@onready var cpu_hitscan_module: CPUHitscanModule = $CPUHitscanModule


func enter(_data := { }) -> void:
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

	_update_players()
	space_state = player.get_world_2d().direct_space_state

	if weapon is ProjectileWeaponResource:
		var projectile_shot := cpu_projectile_module.find_shot(weapon)
		player.cpu_fire_projectile(projectile_shot)
	elif weapon is HitscanWeaponResource:
		var hitscan_shot := cpu_hitscan_module.find_shot(weapon)
		player.cpu_fire_hitscan(hitscan_shot)

	#_reset()[


func _update_players() -> void:
	var _players := get_tree().get_nodes_in_group("players")
	_players.erase(player)
	teammates = _players.filter(
		func(p: Player) -> bool:
			return p.team.get_id() == player.team.get_id(),
	)
	enemies = _players.filter(
		func(p: Player) -> bool:
			return p.team.get_id() != player.team.get_id(),
	)


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


func _reset() -> void:
	cpu_hitscan_module.reset()
	cpu_projectile_module.reset()
