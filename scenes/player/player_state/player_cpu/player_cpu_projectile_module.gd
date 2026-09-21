class_name CPUProjectileModule
extends PlayerCPUWeaponModule

# Bit-wise collision mask for world, hurtbox, bounds.
const PROJECTILE_COLLISION_MASK := 0b100110
const HURTBOX_COLLISION_MASK := 0b100
const WORLD_COLLISION_MASK := 0b10

@export_group("Sampling")
@export var sample_attempts := 32
@export var force_variations := 5
@export var max_iterations := 1500
@export_group("Scoring")
@export var min_score := 0.1
@export_subgroup("Weights")
@export var enemy_distance_weight := 1.0
@export var teammate_distance_weight := 1.0
@export var self_distance_weight := 0.65
@export var enemy_count_weight := 0.2

var sampled_shots: Array[CPUProjectileShot] = []


func find_shot(weapon: ProjectileWeaponResource) -> CPUProjectileShot:
	for chunked_aim_attempts in _generate_aim_attempts_chunks(weapon):
		for aim_attempt: Dictionary in chunked_aim_attempts:
			_sample_shot(weapon, aim_attempt.angle, aim_attempt.force)
		await get_tree().process_frame

	if sampled_shots.is_empty():
		push_warning("No projectile shot found.")
		return null

	return _determine_best_shot(weapon)


func reset() -> void:
	sampled_shots.clear()

	for child in get_children():
		child.queue_free()


# TODO: Dismiss shot if result in suicide
func _sample_shot(weapon: ProjectileWeaponResource, angle: float, force: float) -> void:
	var projectile := weapon.projectile_resource
	var delta := get_physics_process_delta_time()
	var max_sampling_iterations := mini(max_iterations, ceili(projectile.life_time / delta))

	var query_position := cpu.player.global_position + weapon.muzzle_offset.rotated(angle)
	var last_free_position := query_position
	var velocity := Vector2.from_angle(angle) * force
	var sample_iteration := 0

	# Debug
	var line_points: Array[Vector2] = []

	while sample_iteration < max_sampling_iterations:
		sample_iteration += 1

		var query := Utils.create_shape_query(PROJECTILE_COLLISION_MASK, query_position, true, true)
		query.exclude = [cpu.player.hurtbox] # Some projectiles spawn within current hurtbox
		query.shape = projectile.collision_shape

		var collisions := cpu.space_state.intersect_shape(query)

		if _is_query_oob(collisions):
			return

		var normal := _get_world_normal(query_position, projectile.collision_shape)

		# No world collision => continue
		if normal == Vector2.ZERO:
			line_points.append(query_position)
			last_free_position = query_position
			velocity += cpu.player.get_gravity() * delta
			query_position += velocity * delta
			continue

		if not projectile.bounce_enabled:
			break

		# Remember position before collision with world otherwise it's "in" the world
		query_position = last_free_position
		velocity = velocity.bounce(normal) / projectile.bounce_velocity_divider
		line_points.append(query_position)

		# If movement is slow enough => finished
		if velocity.length_squared() < 1.0:
			break

	if debug_pathing:
		_create_debug_line(line_points)

	var shot := _create_shot(weapon, query_position, angle, force)
	sampled_shots.append(shot)


func _get_world_normal(at_position: Vector2, shape: Shape2D) -> Vector2:
	var query := Utils.create_shape_query(WORLD_COLLISION_MASK, at_position, false, true)
	query.shape = shape

	var rest := cpu.space_state.get_rest_info(query)
	return rest.get("normal", Vector2.ZERO)


## Determines the best shot out of all sampled shots.
func _determine_best_shot(weapon: ProjectileWeaponResource) -> CPUProjectileShot:
	var best_shot: CPUProjectileShot
	var best_score := -INF
	var explosion_max_range := weapon.projectile_resource.explosion.damage.max_range

	for shot in sampled_shots:
		if shot.distance_to_self < explosion_max_range:
			var expected_damage := weapon.projectile_resource.explosion.damage.calculate(
				shot.distance_to_self
			)
			if cpu.player.health.health <= expected_damage:
				continue

		var enemy_score := 1.0 - clampf(shot.distance_to_enemy / explosion_max_range, 0, 1)
		var teammate_score := 1.0 - clampf(shot.distance_to_teammate / explosion_max_range, 0, 1)
		var self_score := 1.0 - clampf(shot.distance_to_self / explosion_max_range, 0, 1)

		var score: float = (shot.enemies - shot.teammates) * enemy_count_weight
		score += enemy_score * enemy_distance_weight
		score -= teammate_score * teammate_distance_weight
		score -= self_score * self_distance_weight

		if score > min_score and score > best_score:
			best_shot = shot
			best_score = score

	print("Projectile score: %s" % best_score)

	return best_shot


func _create_shot(
	weapon: ProjectileWeaponResource,
	query_position: Vector2,
	angle: float,
	force: float,
) -> CPUProjectileShot:
	var explosion_max_range := weapon.projectile_resource.explosion.damage.max_range
	var explosion_query := Utils.create_shape_query(
		HURTBOX_COLLISION_MASK,
		query_position,
		true,
		true,
	)
	explosion_query.exclude = [cpu.player.hurtbox]

	var shape := CircleShape2D.new()
	shape.radius = explosion_max_range
	explosion_query.shape = shape

	var explosion_collisions := cpu.space_state.intersect_shape(explosion_query)
	var distance_to_teammate := explosion_max_range
	var distance_to_enemy := explosion_max_range
	var distance_to_self := query_position.distance_to(cpu.player.global_position)
	var enemies_count := 0
	var teammates_count := 0

	for collision in explosion_collisions:
		var collider: HurtboxComponent = collision.collider
		var distance := query_position.distance_to(collider.global_position)

		if collider.is_in_group(cpu.player.team.get_id()):
			distance_to_teammate = minf(distance, distance_to_teammate)
			teammates_count += 1
			continue

		distance_to_enemy = minf(distance, distance_to_enemy)
		enemies_count += 1

	return CPUProjectileShot.new(
		angle,
		distance_to_enemy,
		distance_to_teammate,
		distance_to_self,
		force,
		enemies_count,
		teammates_count,
	)


## Checks whether intersection is within the level's bounds
func _is_query_oob(collisions: Array[Dictionary]) -> bool:
	return collisions.any(
		func(d: Dictionary) -> bool:
			return d.collider is BoundsArea or d.collider is Water,
	)


func _generate_aim_attempts_chunks(weapon: ProjectileWeaponResource) -> Array[Array]:
	var force := weapon.max_force - weapon.min_force # 1000 - 200 = 800
	var force_division := floori(force / force_variations) # 800 / 4 = 200

	# Chunk into aim force variations + 1 to account for max range
	var chunked_aim_attempts: Array[Array] = []
	chunked_aim_attempts.resize(force_variations + 1)

	var angle_step := TAU / sample_attempts
	for chunk_index in range(0, chunked_aim_attempts.size()):
		var chunk: Array = chunked_aim_attempts[chunk_index]
		var chunk_force := weapon.min_force + (force_division * chunk_index)

		for aim_attempt in sample_attempts:
			var angle := AimableHolder.MINIMUM_ROTATION + (angle_step * aim_attempt)
			chunk.append({ "angle": angle, "force": chunk_force })

	return chunked_aim_attempts


class CPUProjectileShot extends CPUShot:
	var distance_to_enemy: float
	var distance_to_teammate: float
	var distance_to_self: float
	var enemies: int
	var teammates: int
	var force: float


	func _init(
		init_angle: float,
		init_distance_to_enemy: float,
		init_distance_to_teammate: float,
		init_distance_to_self: float,
		init_force: float,
		init_enemies: int,
		init_teammates: int,
	) -> void:
		super(init_angle)
		distance_to_enemy = init_distance_to_enemy
		distance_to_teammate = init_distance_to_teammate
		distance_to_self = init_distance_to_self
		enemies = init_enemies
		teammates = init_teammates
		force = init_force
