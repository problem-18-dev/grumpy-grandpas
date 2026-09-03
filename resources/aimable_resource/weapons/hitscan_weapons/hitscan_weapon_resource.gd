class_name HitscanWeaponResource
extends AimableResource

@export_group("Damage")
@export var damage: DamageResource
@export_group("Knockback")
@export var knockback: KnockbackResource
@export_group("Camera")
@export var shake_duration := 0.06
@export var shake_noise: PhantomCameraNoise2D
