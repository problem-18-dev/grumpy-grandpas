class_name CPUProjectileModule
extends PlayerCPUWeaponModule

const COLLISION_MASK := 0b100110

var sampled_shots: Array[CPUProjectileShot] = []


func find_shot(projectile_weapon: ProjectileWeaponResource) -> CPUProjectileShot:
	for angle in _get_aim_angles():
		var force := randf_range(projectile_weapon.min_force, projectile_weapon.max_force)
		_sample_shot(angle, force, projectile_weapon.muzzle_offset)

	return _determine_best_shot()


func reset() -> void:
	sampled_shots.clear()

	for child in get_children():
		child.queue_free()


func _sample_shot(angle: float, force: float, offset: Vector2) -> void:
	var query_position := cpu.player.global_position + offset.rotated(angle)
	var velocity := Vector2.from_angle(angle) * force
	var line := _add_debug_line()

	while true:
		var query := PhysicsPointQueryParameters2D.new()
		query.collide_with_bodies = true
		query.collide_with_areas = true
		query.exclude = [cpu.player.get_rid()]
		query.collision_mask = COLLISION_MASK
		query.position = query_position

		var collisions := cpu.space_state.intersect_point(query)

		# Shot is invalid if out of bounds
		if _is_point_oob(collisions):
			return

		# Only one collision => must be within bound, continue
		if collisions.size() == 1:
			line.add_point(query_position)
			velocity += cpu.player.get_gravity() * get_physics_process_delta_time()
			query_position += velocity * get_physics_process_delta_time()
			continue

		# Direct hit on teammate
		if collisions.any(
			func(c: Dictionary) -> bool:
				return c.collider.is_in_group(cpu.player.team.get_id()),
		):
			return

		# Collision with world or hurtbox
		var distance_to_self := query_position.distance_to(cpu.player.global_position)

		var distance_to_teammate := INF
		for t in cpu.teammates:
			var distance := query_position.distance_to(t.global_position)

			if distance < distance_to_teammate:
				distance_to_teammate = distance

		var distance_to_enemy := INF
		for e in cpu.enemies:
			var distance := query_position.distance_to(e.global_position)

			if distance < distance_to_enemy:
				distance_to_enemy = distance

		var is_direct := collisions.any(
			func(c: Dictionary) -> bool:
				return c.collider is HurtboxComponent,
		)

		var shot := CPUProjectileShot.new(
			distance_to_self,
			distance_to_enemy,
			distance_to_teammate,
			angle,
			force,
			is_direct,
		)
		sampled_shots.append(shot)
		return


## Determines the best shot out of all sampled shots.
## Score: 1000 + Distance to enemy player - distance to teammate player - distance to self
func _determine_best_shot() -> CPUProjectileShot:
	var best_shot := sampled_shots[0]
	var best_score := -INF

	for shot in sampled_shots:
		var enemy_score: float = SHOT_SCORE_BASE - shot.distance_to_enemy
		var teammate_score: float = enemy_score + shot.distance_to_teammate
		var score: float = teammate_score + shot.distance_to_self

		if shot.is_direct:
			score += 500

		if score > best_score:
			best_shot = shot
			best_score = score

	return best_shot


## Checks whether intersection is within the level's bounds
func _is_point_oob(collisions: Array[Dictionary]) -> bool:
	return (
		collisions.is_empty()
		or not collisions.any(
			func(d: Dictionary) -> bool:
				return d.collider is BoundsArea,
		)
	)


func _get_aim_angles() -> Array[float]:
	var step := TAU / cpu.aim_attempts
	var angles: Array[float] = []

	for aim_attempt in cpu.aim_attempts:
		var angle := AimableHolder.MINIMUM_ROTATION + (step * aim_attempt)
		angles.append(angle)

	return angles


class CPUProjectileShot:
	var distance_to_self: float
	var distance_to_enemy: float
	var distance_to_teammate: float
	var angle: float
	var force: float
	var is_direct: bool


	func _init(
		init_distance_to_self: float,
		init_distance_to_enemy: float,
		init_distance_to_teammate: float,
		init_angle: float,
		init_force: float,
		init_is_direct: bool,
	) -> void:
		distance_to_self = init_distance_to_self
		distance_to_enemy = init_distance_to_enemy
		distance_to_teammate = init_distance_to_teammate
		angle = init_angle
		force = init_force
		is_direct = init_is_direct
