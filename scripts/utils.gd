class_name Utils
extends Node


static func create_shape_query(
	collision_mask: int,
	at_position: Vector2,
) -> PhysicsShapeQueryParameters2D:
	var shape_query := PhysicsShapeQueryParameters2D.new()
	shape_query.collision_mask = collision_mask
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = false
	shape_query.transform = Transform2D(0, at_position)
	return shape_query
