class_name PickuppableResource
extends Resource

enum Type {
	WEAPON,
	TOOL,
	HEALTH,
}

@export var name := "Pickuppable"
@export var texture: Texture2D
@export var type := Type.WEAPON
