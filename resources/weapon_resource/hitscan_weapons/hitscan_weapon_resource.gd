class_name HitscanWeaponResource
extends WeaponResource

const DEFAULT_RANGE := 300.0

@export_group("Range")
@export var weapon_range := DEFAULT_RANGE
@export_group("Damage")
@export var damage: DamageResource
