class_name CatalogueResource
extends Resource

@export_group("Weapons")
@export var weapons: Array[ItemResource]
@export var default_weapon: ItemResource
@export_group("Tools")
@export var tools: Array[ItemResource]


func get_all() -> Dictionary[String, Array]:
	return { "weapons": weapons, "tools": tools }
