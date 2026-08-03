@abstract
class_name Weapon
extends Node2D

signal weapon_ready
signal weapon_shot

var _is_enabled := false


func prepare(_weapon_resource) -> void:
	pass


func shoot() -> void:
	pass


func flip(_should_flip: bool) -> void:
	pass
