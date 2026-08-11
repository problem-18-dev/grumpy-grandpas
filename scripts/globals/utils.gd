extends Node

const EXPLOSION := preload("uid://dchrvlerl7kne")


func create_shape_query(
	collision_mask: int,
	at_position: Vector2,
	collide_with_area := true,
	collide_with_bodies := false,
) -> PhysicsShapeQueryParameters2D:
	var shape_query := PhysicsShapeQueryParameters2D.new()
	shape_query.collision_mask = collision_mask
	shape_query.collide_with_areas = collide_with_area
	shape_query.collide_with_bodies = collide_with_bodies
	shape_query.transform = Transform2D(0, at_position)
	return shape_query


func create_explosion(explosion_resource: ExplosionResource, explode_position: Vector2) -> void:
	var explosion := EXPLOSION.instantiate()
	explosion.prepare(explosion_resource)

	var explosions := get_tree().get_first_node_in_group("explosions")
	explosions.add_child(explosion)
	explosion.explode(explode_position)
