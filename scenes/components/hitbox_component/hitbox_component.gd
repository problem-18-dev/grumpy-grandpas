@tool
class_name HitboxComponent
extends Area2D

const HITBOX_COLOR := Color(0.996, 0.804, 0.0, 0.392)

var _targets_to_hit: Array[HurtboxComponent]
var _collision_shape: CollisionShape2D


func _ready() -> void:
	_collision_shape = find_children("*", "CollisionShape2D")[0]
	if not _collision_shape:
		return

	_collision_shape.debug_color = HITBOX_COLOR


func hit_targets(damage: int, damage_falloff_curve: Curve) -> void:
	if _targets_to_hit.is_empty():
		return

	for target in _targets_to_hit:
		var distance_to_target := global_position.distance_to(target.global_position)
		var distance_ratio := float(distance_to_target / _collision_shape.shape.radius)
		var calculated_damage := roundi(damage * damage_falloff_curve.sample(distance_ratio))
		target.hit(calculated_damage)


func _on_area_entered(area: HurtboxComponent) -> void:
	_targets_to_hit.append(area)


func _on_area_exited(area: HurtboxComponent) -> void:
	_targets_to_hit.erase(area)
