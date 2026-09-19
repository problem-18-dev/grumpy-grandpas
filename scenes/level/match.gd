extends BaseLevel

var _spawn_points: Array[SpawnGenerator.SpawnPoint] = []

@onready var spawn_generator: SpawnGenerator = $SpawnGenerator
@onready var spawn_follow: PathFollow2D = $SpawnPath/SpawnFollow
@onready var bounds_area: BoundsArea = $BoundsArea

@onready var top: CollisionShape2D = $BoundsArea/Top
@onready var right: CollisionShape2D = $BoundsArea/Right
@onready var bottom: CollisionShape2D = $BoundsArea/Bottom
@onready var left: CollisionShape2D = $BoundsArea/Left


## Returns new or cached spawn points
func get_spawn_points() -> Array[SpawnGenerator.SpawnPoint]:
	if _spawn_points.is_empty():
		_spawn_points = spawn_generator.generate_spawn_points()

	return _spawn_points


func get_spawn_follow() -> PathFollow2D:
	return spawn_follow


## Cleans up any entities beyond the bounds
func cleanup() -> void:
	bounds_area.cleanup()


## Returns the level's bounds in following order: top, right, bottom, left
func get_bounds() -> Array[int]:
	return [
		roundi(top.global_position.y),
		roundi(right.global_position.x),
		roundi(bottom.global_position.y),
		roundi(left.global_position.x),
	]


func _on_bounds_area_projectile_exited() -> void:
	projectile_exited.emit()
