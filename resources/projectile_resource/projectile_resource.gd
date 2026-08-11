class_name ProjectileResource
extends Resource

const DEFAULT_BOUNCE_DIVIDER := 1.75
const DEFAULT_LIFE_TIME := 10.0

@export var name := "Projectile"
@export_group("Properties")
@export var texture: Texture2D
@export var collision_shape: Shape2D
@export_group("Bounce")
@export var bounce_enabled: bool
@export var bounce_velocity_divider := DEFAULT_BOUNCE_DIVIDER
@export_group("Lifetime")
@export var life_time := DEFAULT_LIFE_TIME
@export_group("Explosion")
@export var explosion: ExplosionResource
