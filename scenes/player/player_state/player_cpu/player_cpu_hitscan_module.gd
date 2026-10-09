class_name CPUHitscanModule
extends PlayerCPUWeaponModule

const COLLISION_MASK := 0b110

@export_group("Weights")
@export var health_weight := 0.25
@export var distance_weight := 1.0

var sampled_shots: Array[CPUHitscanShot] = []


## Finds best direct shot, null if none found
func find_shot(weapon: HitscanWeaponResource) -> CPUHitscanShot:
	for enemy in _get_enemies():
		_sample_shot(weapon, enemy)

	return _determine_best_shot(weapon)


func reset() -> void:
	sampled_shots.clear()

	for child in get_children():
		child.queue_free()


func _sample_shot(weapon: HitscanWeaponResource, enemy: Player) -> void:
	var enemy_position := enemy.global_position
	var angle := cpu.player.global_position.angle_to_point(enemy_position)
	var fire_position := cpu.player.global_position + weapon.position_offset + weapon \
			.muzzle_offset \
			.rotated(angle)

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

	# Skip if not direct on enemy
	if collider is not HurtboxComponent:
		return

	var collision_position: Vector2 = collision.position
	var collision_distance := fire_position.distance_to(collision_position)

	if debug_pathing:
		_create_debug_line([fire_position, collision_position])

	var shot := CPUHitscanShot.new(angle, collision_distance, enemy)
	sampled_shots.append(shot)


func _determine_best_shot(weapon: HitscanWeaponResource) -> CPUHitscanShot:
	var best_shot: CPUHitscanShot
	var best_score := -INF
	var hitscan_max_range := weapon.damage.max_range

	for shot in sampled_shots:
		# Discard shots outside the weapon's max range.
		if shot.distance > hitscan_max_range:
			continue

		# Prioritize low health and close enemies
		var health_ratio := float(shot.enemy.health.health) / float(shot.enemy.health.max_health)
		var score := -health_ratio * health_weight
		score -= shot.distance / hitscan_max_range * distance_weight

		if score > best_score:
			best_score = score
			best_shot = shot

	return best_shot


func _get_enemies() -> Array[Player]:
	var players := get_tree().get_nodes_in_group("player")

	# Enemy = Different team id and hurtbox enabled
	var enemies := players.filter(
		func(p: Player) -> bool:
			return p.team.get_id() != cpu.player.team.get_id() and p.hurtbox.enabled,
	)

	return enemies


class CPUHitscanShot extends CPUShot:
	var distance: float
	var enemy: Player


	func _init(init_angle: float, init_distance: float, init_enemy: Player) -> void:
		super(init_angle)
		distance = init_distance
		enemy = init_enemy
