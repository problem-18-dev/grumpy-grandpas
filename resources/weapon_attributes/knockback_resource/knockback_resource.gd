class_name KnockbackResource
extends Resource

const DEFAULT_KNOCKBACK_RANGE := 45.0
const DEFAULT_KNOCKBACK_FORCE := 150.0

@export_group("Range")
## Only relevant for [Projectile]
@export var max_range := DEFAULT_KNOCKBACK_RANGE
@export_group("Force")
@export var base_force := DEFAULT_KNOCKBACK_FORCE
@export var falloff_curve: Curve


## Calculates knockback based on distance to target
func calculate(distance_to_target: float) -> float:
	assert(falloff_curve, "Trying to calculate knockback without falloff curve")

	var fallback_ratio := distance_to_target / max_range
	var fallback_sample := falloff_curve.sample(fallback_ratio)
	return fallback_sample * base_force


## Calculates knockback based on distance to target and hitscan range
func calculate_for_hitscan(distance_to_target: float, hitscan_range: float) -> float:
	var fallback_ratio := distance_to_target / hitscan_range
	var fallback_sample := falloff_curve.sample(fallback_ratio)
	return fallback_sample * base_force
