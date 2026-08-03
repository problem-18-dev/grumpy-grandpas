class_name ProjectileResource
extends Resource

@export var name := "Projectile"
@export_group("Properties")
@export var texture: Texture2D
@export var collision_shape: Shape2D
@export var should_bounce: bool
@export_group("Range")
@export var range_radius := 35.0
@export_group("Damage")
@export var damage := 100
@export var damage_falloff_curve: Curve
