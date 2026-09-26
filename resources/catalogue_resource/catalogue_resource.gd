class_name CatalogueResource
extends Resource

@export_group("Weapons")
@export var weapons: Array[ItemResource]
@export var default_weapon: ItemResource
@export_group("Tools")
@export var tools: Array[ItemResource]


func get_all() -> Dictionary[String, Array]:
	return { "weapons": weapons, "tools": tools }


func get_hitscan_weapons() -> Array[ItemResource]:
	return weapons.filter(
		func(w: ItemResource) -> bool:
			return w.aimable_resource is HitscanWeaponResource,
	)


func get_projectile_weapons() -> Array[ItemResource]:
	return weapons.filter(
		func(w: ItemResource) -> bool:
			return w.aimable_resource is ProjectileWeaponResource,
	)
