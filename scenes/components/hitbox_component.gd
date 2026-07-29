@tool
class_name HitboxComponent
extends Area2D

const HITBOX_COLOR := Color(0.0, 1.0, 0.0, 0.392)

signal hit


func _ready() -> void:
	var child := find_child("*")
	if child and child is CollisionShape2D:
		child.debug_color = HITBOX_COLOR


func _on_area_entered(_area: Area2D) -> void:
	hit.emit()
