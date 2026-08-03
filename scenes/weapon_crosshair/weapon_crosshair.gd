@tool
class_name WeaponCrosshair
extends Sprite2D

@export_group("Properties")
@export var fade_duration := 0.15


func _ready() -> void:
	modulate.a = 0.0


func setup(x_offset: float) -> void:
	position = Vector2(x_offset, 0)


func enable() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)


func disable() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
