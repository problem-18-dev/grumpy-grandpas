class_name ExplosionResource
extends Resource

const DEFAULT_CARVE_RADIUS := 48.0

@export_group("Carving")
@export var carve_radius := DEFAULT_CARVE_RADIUS
@export_group("Damage")
@export var damage: DamageResource
@export_group("Knockback")
@export var knockback: KnockbackResource
