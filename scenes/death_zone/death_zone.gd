extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Projectile:
		body.cleanup()

	if body is Player:
		body.queue_free()
