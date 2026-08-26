class_name PickupComponent
extends Area2D

signal picked_up(by: Player)


func _on_body_entered(body: Player) -> void:
	picked_up.emit(body)
