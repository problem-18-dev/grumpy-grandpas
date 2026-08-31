class_name HealthComponent
extends Node

signal health_changed(new_health: int, amount: int)
signal died

const DEFAULT_HEALTH := 100

@export_group("Properties")
@export var max_health := DEFAULT_HEALTH

var _dead := false

@onready var health := max_health


func get_health() -> int:
	return health


func add_health(amount: int) -> void:
	var new_health := health + amount
	new_health = mini(max_health, health)

	health_changed.emit(new_health, mini(amount, max_health - health))
	health = new_health


func take_health(amount: int) -> void:
	if _dead:
		return

	var new_health := health - amount
	new_health = maxi(0, new_health)

	health_changed.emit(new_health, -mini(amount, health))
	health = new_health

	if health <= 0:
		_dead = true
		died.emit()
