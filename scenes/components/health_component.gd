class_name HealthComponent
extends Node

signal died

const DEFAULT_HEALTH := 100

@export_group("Properties")
@export var max_health := DEFAULT_HEALTH

var _health := max_health


func add_health(amount: int) -> void:
	_health += amount
	_health = mini(max_health, _health)


func take_health(amount: int) -> void:
	_health -= amount
	_health = maxi(0, _health)

	if _health <= 0:
		died.emit()
