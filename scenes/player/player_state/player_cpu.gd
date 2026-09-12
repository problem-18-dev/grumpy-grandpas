class_name PlayerStateCPU
extends PlayerState

@export_group("Aiming")
@export var aim_attempts := 20

var teammates: Array[Node]
var enemies: Array[Node]
var space_state: PhysicsDirectSpaceState2D

@onready var cpu_projectile_module: CPUProjectileModule = $CPUProjectileModule
@onready var cpu_hitscan_module: CPUHitscanModule = $CPUHitscanModule


func enter(_data := { }) -> void:
	var weapon := _get_random_weapon()
	_find_shot(weapon)


func _find_shot(weapon: AimableResource) -> void:
	# Wait for game to be idle
	await get_tree().process_frame

	_update_players()
	space_state = player.get_world_2d().direct_space_state

	if weapon is ProjectileWeaponResource:
		cpu_projectile_module.find_shot(weapon)
		return

	if weapon is HitscanWeaponResource:
		cpu_hitscan_module.find_shot(weapon)


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


func _get_random_weapon() -> AimableResource:
	var locked_items := player.team.get_locked_items()
	var catalogue := GameManager.get_catalogue()
	var available_items: Array[ItemResource] = catalogue.weapons.filter(
		func(weapon: ItemResource) -> bool:
			return not locked_items.has(weapon),
	)
	var item: ItemResource = available_items.pick_random()

	return item.aimable_resource
