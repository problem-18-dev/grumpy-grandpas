extends BaseLevel

var _spawn_points: Array[Dictionary] = []

@onready var spawn_generator: SpawnGenerator = $SpawnGenerator
@onready var spawn_follow: PathFollow2D = $SpawnPath/SpawnFollow
@onready var bounds_area: BoundsArea = $BoundsArea


func _ready() -> void:
	_spawn_points = spawn_generator.generate_spawn_points()


func get_spawn_points() -> Array[Dictionary]:
	return _spawn_points


func get_spawn_follow() -> PathFollow2D:
	return spawn_follow


func cleanup() -> void:
	bounds_area.cleanup()


func _on_bounds_area_projectile_exited() -> void:
	projectile_exited.emit()
