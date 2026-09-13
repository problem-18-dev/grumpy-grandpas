class_name CPUHitscanModule
extends PlayerCPUWeaponModule

const RAY_LENGTH := 1000
const COLLISION_MASK := 0b110

var sampled_shots: Array[CPUHitscanShot] = []


func find_shot(weapon: HitscanWeaponResource) -> CPUHitscanShot:
	for enemy_position in _get_enemy_positions():
		_sample_shot(enemy_position, weapon.muzzle_offset)

	return _determine_best_shot()


func reset() -> void:
	sampled_shots.clear()

	for child in get_children():
		child.queue_free()


func _sample_shot(enemy_position: Vector2, offset: Vector2) -> void:
	var aim := cpu.player.global_position + offset.rotated(
		cpu.player.global_position.angle_to_point(enemy_position)
	)
	var line := Line2D.new()
	line.width = 2
	line.default_color = Color(0.1, 0.4, 0.0, 1.0)
	add_child(line)

	var query := PhysicsRayQueryParameters2D.create(
		aim,
		enemy_position,
		COLLISION_MASK,
		[cpu.player.get_rid()],
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

	var distance := aim.distance_to(collider.global_position)
	var is_direct := collider is Player

	if debug_pathing:
		line.add_point(aim)
		line.add_point(enemy_position)

	var shot := CPUHitscanShot.new(aim.angle(), distance, is_direct)
	sampled_shots.append(shot)


func _determine_best_shot() -> CPUHitscanShot:
	if sampled_shots.is_empty():
		return null

	var best_shot := sampled_shots[0]
	var best_score := -INF

	for shot in sampled_shots:
		var score: float = SHOT_SCORE_BASE - shot.distance

		if shot.is_direct:
			score += 500

		if score > best_score:
			best_score = score
			best_shot = shot

	return best_shot


func _get_enemy_positions() -> Array[Vector2]:
	var enemy_positions: Array[Vector2] = []
	for enemy in cpu.enemies:
		enemy_positions.append(enemy.global_position)

	return enemy_positions


class CPUHitscanShot:
	var angle: float
	var distance: float
	var is_direct: bool


	func _init(init_angle: float, init_distance: float, init_is_direct: bool) -> void:
		angle = init_angle
		distance = init_distance
		is_direct = init_is_direct
