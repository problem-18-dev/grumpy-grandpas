@tool
extends Node2D

@export var size: Vector2

@onready var collision_shape_2d: CollisionShape2D = $WaterArea/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	collision_shape_2d.shape.size = size
	sprite_2d.texture.size = size


func _on_water_area_body_entered(body: Player) -> void:
	body.drown()
