class_name AimableResource
extends Resource

const DEFAULT_CROSSHAIR_DISTANCE := 100.0

@export_file("*.tscn") var scene: String
@export_group("Properties")
@export var texture: Texture2D
@export var muzzle_offset: Vector2
@export var crosshair_distance := DEFAULT_CROSSHAIR_DISTANCE
@export_group("Ammunition")
@export var ammo := 1
