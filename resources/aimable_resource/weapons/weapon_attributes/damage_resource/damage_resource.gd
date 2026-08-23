class_name DamageResource
extends Resource

const DEFAULT_DAMAGE := 48
const DEFAULT_RANGE := 300.0

@export_group("Range")
@export var max_range := DEFAULT_RANGE
@export_group("Damage")
@export var base_damage := DEFAULT_DAMAGE
@export var falloff_curve: Curve


## Calculates damage based on distance to target
func calculate(distance_to_target: float) -> int:
	assert(falloff_curve, "Trying to calculate damage without falloff curve")

	var damage_ratio := distance_to_target / max_range
	var damage_sample := falloff_curve.sample(damage_ratio)
	return roundi(damage_sample * base_damage)
