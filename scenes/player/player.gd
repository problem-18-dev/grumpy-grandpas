class_name Player
extends CharacterBody2D

const LEFT := -1
const RIGHT := 1

@export_group("States")
@export_subgroup("Idle")
@export_subgroup("Walk")
@export var movement_speed := 100.0
@export_subgroup("Air")
@export var jump_force := -350.0
@export var jump_backwards_force := -400.0
@export var jump_backwards_velocity := 25.0

var last_movement_direction: int

@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var health: HealthComponent = $HealthComponent


func _on_health_component_died() -> void:
	pass


func _on_hitbox_component_hit() -> void:
	pass
