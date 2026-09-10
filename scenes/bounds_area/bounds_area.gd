class_name BoundsArea
extends Area2D

signal projectile_exited

var _present_entities: Array[Node2D] = []


func cleanup() -> void:
	_present_entities.map(_free_present_entity)
	_present_entities = []


func _free_present_entity(entity: Node2D) -> void:
	if not is_instance_valid(entity):
		return

	if entity is Projectile:
		entity.destroy()

	if entity is Player:
		entity.queue_free()


func _on_body_exited(body: Node2D) -> void:
	_present_entities.append(body)

	if body is Projectile:
		projectile_exited.emit()
