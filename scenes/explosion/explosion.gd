class_name Explosion
extends Node2D

@onready var timer: Timer = $Timer


func _ready() -> void:
	EventSystem.business.busy_started.emit(self)
	EventSystem.camera.request_follow.emit(self, GameCamera.Priority.MID)
	timer.start()


func carve_terrain(carve_radius: float) -> void:
	var terrain: DestructiblePolygon2D = get_tree().get_first_node_in_group("terrain")
	if not terrain:
		return

	var carve_polygon := DestructiblePolygon2D.build_circle_polygon(carve_radius)
	terrain.destruct(carve_polygon, global_position)


func _on_timer_timeout() -> void:
	EventSystem.business.busy_finished.emit(self)
	EventSystem.camera.revoke_follow.emit(self)
	queue_free()
