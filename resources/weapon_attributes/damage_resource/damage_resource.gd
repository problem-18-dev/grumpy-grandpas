class_name DamageResource
extends Resource

const DEFAULT_DAMAGE := 50


@export_group("Damage")
@export var damage := DEFAULT_DAMAGE
@export var damage_falloff_curve: Curve


func calculate_damage(distance: float, damage_range: float) -> int:
	if not damage_falloff_curve:
		push_warning("No damage falloff curve given for %s" % resource_path)
		return damage

	var damage_ratio := distance / damage_range
	var damage_falloff := damage_falloff_curve.sample(damage_ratio)
	var calculated_damage := roundi(damage * damage_falloff)
	return calculated_damage
