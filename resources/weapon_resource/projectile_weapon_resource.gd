class_name ProjectileWeaponResource
extends WeaponResource

const MINIMUM_FORCE := 100.0
const MAXIMUM_FORCE := 400.0

@export_group("Charge")
@export var min_force := MINIMUM_FORCE
@export var max_force := MAXIMUM_FORCE
@export_group("Projectile")
@export var projectile_resource: ProjectileResource
