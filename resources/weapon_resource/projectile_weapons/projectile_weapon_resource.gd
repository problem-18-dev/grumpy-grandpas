class_name ProjectileWeaponResource
extends WeaponResource

const MINIMUM_FORCE := 200.0
const MAXIMUM_FORCE := 1000.0

@export_group("Charge")
@export var min_force := MINIMUM_FORCE
@export var max_force := MAXIMUM_FORCE
@export var charge_time := 1.0
@export_group("Projectile")
@export var projectile_resource: ProjectileResource
