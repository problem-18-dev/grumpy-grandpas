class_name KnockbackResource
extends Resource

const DEFAULT_KNOCKBACK_RADIUS := 45.0
const DEFAULT_KNOCKBACK_FORCE := 150.0

@export_group("Radius")
## Only relevant for [Projectile]
@export var knockback_radius := DEFAULT_KNOCKBACK_RADIUS
@export_group("Force")
@export var knockback_force := DEFAULT_KNOCKBACK_FORCE
@export var knockback_force_falloff_curve: Curve


func calculate_projectile_knockback(distance: float) -> float:
	var knockback_ratio := distance / knockback_radius
	var knockback_falloff := knockback_force_falloff_curve.sample(knockback_ratio)
	return knockback_force * knockback_falloff


func calculate_hitscan_knockback(distance: float, hitscan_range: float) -> float:
	var knockback_ratio := distance / hitscan_range
	var knockback_falloff := knockback_force_falloff_curve.sample(knockback_ratio)
	return knockback_force * knockback_falloff
