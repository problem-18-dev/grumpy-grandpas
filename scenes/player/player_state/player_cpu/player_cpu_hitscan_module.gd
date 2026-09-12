class_name CPUHitscanModule
extends PlayerCPUWeaponModule

const RAY_LENGTH := 1000
const COLLISION_MASK := 0b110


func _get_configuration_warnings() -> PackedStringArray:
	if cpu is not PlayerStateCPU:
		return ["Must be child of the player CPU state"]
	return []


func find_shot(weapon: HitscanWeaponResource) -> Dictionary:
	for angle in _get_aim_angles():
		_sample_shot(angle, weapon.muzzle_offset)

	var best_shot := _determine_best_shot()

	if best_shot.is_empty():
		print("AI found no hitscan shot.")
		return { }

	return best_shot


func _sample_shot(angle: float, offset: Vector2) -> void:
	var aim := offset.rotated(angle)

	while true:
		var query := PhysicsRayQueryParameters2D.create(
			aim,
			aim + Vector2.ONE * RAY_LENGTH,
			COLLISION_MASK,
			[cpu.player.get_rid()],
		)
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var collision := cpu.space_state.intersect_ray(query)

		if collision.is_empty():
			return

		var collider: Node2D = collision.collider

		if collider is HurtboxComponent:
			var muzzle_position := cpu.player.global_position + aim
			var distance := muzzle_position.distance_to(collider.global_position)
			sampled_shots.append({ "angle": angle, "distance": distance })

		return


func _determine_best_shot() -> Dictionary:
	if sampled_shots.is_empty():
		return { }

	var best_shot := sampled_shots[0]
	var best_score := -INF

	for shot in sampled_shots:
		var score: float = SHOT_SCORE_BASE - shot.distance

		if score > best_score:
			best_score = score
			best_shot = shot

	return best_shot


func _get_aim_angles() -> Array[float]:
	var angles: Array[float] = []
	for enemy in cpu.enemies:
		var angle := cpu.player.global_position.angle_to_point(enemy.global_position)
		angles.append(angle)

	return angles
