@abstract
class_name BaseLevel
extends Node2D

signal projectile_exited


@abstract func get_spawn_points() -> Array[Dictionary]


@abstract func get_spawn_follow() -> PathFollow2D


@abstract func cleanup() -> void
