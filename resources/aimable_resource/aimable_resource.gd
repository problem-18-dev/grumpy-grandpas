class_name AimableResource
extends Resource

const DEFAULT_CROSSHAIR_DISTANCE := 100.0

@export_file("*.tscn") var scene: String
@export_group("Properties")
@export var texture: Texture2D
@export_group("Muzzle")
@export var muzzle_offset: Vector2
@export_group("Crosshair")
@export var crosshair_distance := DEFAULT_CROSSHAIR_DISTANCE
