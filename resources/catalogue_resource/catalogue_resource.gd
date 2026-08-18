class_name CatalogueResource
extends Resource

@export_group("Weapons")
@export var weapons: Array[AimableResource]
@export var default_weapon: AimableResource
@export_group("Tools")
@export var tools: Array[AimableResource]


func get_all() -> Dictionary[String, Array]:
	return {
		"weapons": weapons,
		"tools": tools,
	}
