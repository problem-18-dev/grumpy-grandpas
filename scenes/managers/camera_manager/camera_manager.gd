class_name CameraManager
extends Node2D

@onready var game_camera: GameCamera = $GameCamera


func set_limits(bounds: Array[int]) -> void:
	game_camera.limit_top = bounds[0]
	game_camera.limit_right = bounds[1]
	game_camera.limit_bottom = bounds[2]
	game_camera.limit_left = bounds[3]
