@tool
class_name HurtboxComponent
extends Area2D

const HURTBOX_COLOR := Color(0.0, 1.0, 0.0, 0.392)

signal hurt(amount: int)


func _ready() -> void:
	var children := find_children("*", "CollisionShape2D")
	for child: CollisionShape2D in children:
		child.debug_color = HURTBOX_COLOR


func hit(amount: int) -> void:
	Debug.log("Hit by %s" % amount)
	hurt.emit(amount)
