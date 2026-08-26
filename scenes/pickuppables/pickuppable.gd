@tool
class_name Pickuppable
extends CharacterBody2D

signal picked_up(by: Player, type: PickuppableResource.Type)
signal spawned

const BOUNCINESS := 0.35
const MIN_BOUNCE_SPEED := 40.0

@export var resource: PickuppableResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var label: Label = $Label


func _ready() -> void:
	if not resource:
		return

	sprite.texture = resource.texture
	label.text = resource.name
	floor_max_angle = Player.FLOOR_MAX_ANGLE


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	velocity.y += get_gravity().y * delta
	move_and_slide()


func setup(new_resource: PickuppableResource) -> void:
	resource = new_resource


func spawn(spawn_position: Vector2) -> void:
	EventSystem.camera.request_follow.emit(self, GameCamera.Priority.HIGH, GameCamera.Zoom.NEAR)
	spawn_timer.start()

	var shape: RectangleShape2D = collision_shape.shape
	var offset := shape.size.y / 2
	global_position = spawn_position
	global_position.y -= offset


func _on_pickup_component_picked_up(by: Player) -> void:
	assert(resource, "Picked up without resource.")
	Debug.log("Picked up %s by %s" % [resource.name, by.name])

	picked_up.emit(by, resource.type)
	EventSystem.camera.revoke_follow.emit(self)
	queue_free()


func _on_spawn_timer_timeout() -> void:
	spawned.emit()
	EventSystem.camera.revoke_follow.emit(self)
