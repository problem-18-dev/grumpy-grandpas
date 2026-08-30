class_name HealthComponent
extends Node

signal health_added(amount: int)
signal health_taken(amount: int)
signal died

const DEFAULT_HEALTH := 100

@export_group("Properties")
@export var max_health := DEFAULT_HEALTH

var _dead := false

@onready var _health := max_health


func add_health(amount: int) -> void:
	health_added.emit(mini(amount, max_health - _health))

	_health += amount
	_health = mini(max_health, _health)


func take_health(amount: int) -> void:
	if _dead:
		return

	health_taken.emit(mini(amount, _health))

	_health -= amount
	_health = maxi(0, _health)

	if _health <= 0:
		_dead = true
		died.emit()
