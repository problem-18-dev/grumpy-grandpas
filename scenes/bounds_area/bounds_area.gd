class_name BoundsArea
extends Area2D

signal projectile_exited

var _present_entities: Array[Node2D] = []


func cleanup() -> void:
	for entity: Node2D in _present_entities:
		_free_present_entity(entity)

	_present_entities = []


func _free_present_entity(entity: Node2D) -> void:
	if entity is Projectile:
		entity.destroy()

	if entity is Player:
		entity.queue_free()


func _on_body_exited(body: Node2D) -> void:
	_present_entities.append(body)

	if body is Projectile:
		projectile_exited.emit()
