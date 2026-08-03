@tool
class_name HitboxComponent
extends Area2D

const HITBOX_COLOR := Color(1.0, 0.8, 0.0, 0.4)

@export_group("Properties")
@export var damage: int

var _collision_shape: CollisionShape2D


func _ready() -> void:
	_collision_shape = find_children("*", "CollisionShape2D")[0]
	if not _collision_shape:
		return

	_collision_shape.debug_color = HITBOX_COLOR


func _on_area_entered(area: HurtboxComponent) -> void:
	area.hit(damage)
