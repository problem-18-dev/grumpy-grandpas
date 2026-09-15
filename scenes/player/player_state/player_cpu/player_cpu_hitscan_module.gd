class_name CPUHitscanModule
extends PlayerCPUWeaponModule

const RAY_LENGTH := 1000
const COLLISION_MASK := 0b110

var sampled_shots: Array[CPUHitscanShot] = []


func find_shot(weapon: HitscanWeaponResource) -> CPUHitscanShot:
	for enemy in _get_enemies():
		_sample_shot(weapon, enemy)

	if sampled_shots.is_empty():
		push_warning("No hitscan shot found.")
		return null

	return _determine_best_shot(weapon)


func reset() -> void:
	sampled_shots.clear()

	for child in get_children():
		child.queue_free()


func _sample_shot(weapon: HitscanWeaponResource, enemy: Player) -> void:
	var enemy_position := enemy.global_position
	var angle := cpu.player.global_position.angle_to_point(enemy_position)
	var fire_position := cpu.player.global_position + weapon.muzzle_offset.rotated(angle)

	var query := PhysicsRayQueryParameters2D.create(
		fire_position,
		enemy_position,
		COLLISION_MASK,
		[cpu.player.hurtbox],
	)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var collision := cpu.space_state.intersect_ray(query)

	if collision.is_empty():
		return

	var collider: Node2D = collision.collider

	# Skip if direct hit on teammate
	if collider.is_in_group(cpu.player.team.get_id()):
		return

	var is_direct := collider is HurtboxComponent
	var collision_position: Vector2 = collision.position
	var collision_distance := fire_position.distance_to(collision_position)

	if debug_pathing:
		_create_debug_line([fire_position, collision_position])

	var shot := CPUHitscanShot.new(angle, collision_distance, enemy, is_direct)
	sampled_shots.append(shot)


func _determine_best_shot(weapon: HitscanWeaponResource) -> CPUHitscanShot:
	var best_shot: CPUHitscanShot
	var best_score: float
	var hitscan_max_range := weapon.damage.max_range

	for shot in sampled_shots:
		var score := 0.0

		# First decide priority based on player health
		var enemy_max_health := shot.enemy.health.max_health
		var enemy_health := inverse_lerp(0, enemy_max_health, shot.enemy.health.health)
		score = 1.0 - enemy_health

		# Weigh distance second, distance should still win if close enough
		var enemy_score := inverse_lerp(hitscan_max_range, 0, shot.distance)
		var weighted_enemy_score := enemy_score * cpu.enemy_reward_weight
		score = score + clampf(weighted_enemy_score, 0, 1)

		if score >= cpu.aim_min_score and score > best_score:
			best_score = score
			best_shot = shot

	return best_shot


func _get_enemies() -> Array[Player]:
	var players := get_tree().get_nodes_in_group("players")

	var enemies := players.filter(
		func(p: Player) -> bool:
			return p.team.get_id() != cpu.player.team.get_id(),
	)

	return enemies


class CPUHitscanShot extends CPUShot:
	var distance: float
	var enemy: Player
	var is_direct: bool


	func _init(
		init_angle: float,
		init_distance: float,
		init_enemy: Player,
		init_is_direct: bool,
	) -> void:
		super(init_angle)
		distance = init_distance
		enemy = init_enemy
		is_direct = init_is_direct
