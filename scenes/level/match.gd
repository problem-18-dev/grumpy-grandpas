@tool
extends BaseLevel

var _spawn_points: Array[SpawnGenerator.SpawnPoint] = []

@onready var spawn_generator: SpawnGenerator = $SpawnGenerator
@onready var spawn_follow: PathFollow2D = $SpawnPath/SpawnFollow
@onready var bounds_area: BoundsArea = $BoundsArea
@onready var game_camera: GameCamera = $Camera/GameCamera

@onready var top: CollisionShape2D = $BoundsArea/Top
@onready var right: CollisionShape2D = $BoundsArea/Right
@onready var bottom: CollisionShape2D = $BoundsArea/Bottom
@onready var left: CollisionShape2D = $BoundsArea/Left


func _ready() -> void:
	_limit_camera()


## Returns new or cached spawn points
func get_spawn_points() -> Array[SpawnGenerator.SpawnPoint]:
	if _spawn_points.is_empty():
		_spawn_points = spawn_generator.generate_spawn_points()

	return _spawn_points


func get_spawn_follow() -> PathFollow2D:
	return spawn_follow


func cleanup() -> void:
	bounds_area.cleanup()


func _limit_camera() -> void:
	game_camera.limit_bottom = roundi(bottom.global_position.y)
	game_camera.limit_top = roundi(top.global_position.y)
	game_camera.limit_left = roundi(left.global_position.x)
	game_camera.limit_right = roundi(right.global_position.x)


func _on_bounds_area_projectile_exited() -> void:
	projectile_exited.emit()
