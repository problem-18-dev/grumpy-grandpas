class_name Crosshair
extends Sprite2D

@export_group("Properties")
@export var fade_duration := 0.15


func enable() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)


func disable() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
