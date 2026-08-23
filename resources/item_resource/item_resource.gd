class_name ItemResource
extends Resource

@export var name := "Item"
@export var icon: Texture2D
@export_group("Info")
@export var description := "This is an amazing item!"
@export_group("Aimable")
@export var aimable_resource: AimableResource
@export_group("Player State")
@export var set_player_state_on_equip := false
@export var player_state: String
