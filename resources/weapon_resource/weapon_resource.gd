class_name WeaponResource
extends Resource

const DEFAULT_CROSSHAIR_DISTANCE := 100.0
const DEFAULT_DAMAGE := 100.0

@export var name := "Weapon"
@export_group("Properties")
@export var texture: Texture2D
@export_group("Muzzle")
@export var muzzle_offset: Vector2
@export_group("Crosshair")
@export var crosshair_distance := DEFAULT_CROSSHAIR_DISTANCE
@export_group("Damage")
@export var damage := DEFAULT_DAMAGE
