@abstract
class_name Weapon
extends Node2D

@warning_ignore("unused_signal")
signal weapon_ready
@warning_ignore("unused_signal")
signal weapon_shot

@warning_ignore("unused_private_class_variable")
var _is_enabled := false


func prepare(_weapon_resource) -> void:
	pass


func shoot() -> void:
	pass


func flip(_should_flip: bool) -> void:
	pass
