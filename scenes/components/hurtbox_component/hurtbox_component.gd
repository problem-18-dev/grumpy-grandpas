@tool
class_name HurtboxComponent
extends Area2D

signal hurt(amount: int)
signal knockbacked(force: float, angle: float)

const HURTBOX_COLOR := Color(0.0, 1.0, 0.0, 0.392)

@export_group("Health")
@export var health_component: HealthComponent


func _ready() -> void:
	var children := find_children("*", "CollisionShape2D")
	for child: CollisionShape2D in children:
		child.debug_color = HURTBOX_COLOR


func hit(amount: int) -> void:
	Debug.log("Hit by %s" % amount)
	hurt.emit(amount)

	if health_component:
		health_component.take_health(amount)


func knockback(knockback_force: float, knockback_angle: float) -> void:
	if knockback_force == null or knockback_angle == null:
		push_warning("Knockback force or angle is missing, skipping knockback")
		return

	knockbacked.emit(knockback_force, knockback_angle)
