@abstract
class_name Aimable
extends Node2D

## Emits when the weapon or tool should use ammo
signal fired
## Emits when the weapon or tool has been used and should adjust player state
signal used(player_state: String, state_data: Dictionary)

@export var aimable_resource: AimableResource

var _is_enabled := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var crosshair: Crosshair = $Crosshair


func _ready() -> void:
	if not aimable_resource:
		return

	sprite.texture = aimable_resource.texture
	crosshair.position = Vector2(aimable_resource.crosshair_distance, 0)


func prepare(new_aimable_resource: AimableResource) -> void:
	aimable_resource = new_aimable_resource


func shoot() -> void:
	pass


## Flips the weapon's sprite
func flip(should_flip: bool) -> void:
	sprite.flip_h = should_flip
	sprite.flip_v = should_flip
	crosshair.flip_v = should_flip


## Disable shooting and show crosshair
func enable() -> void:
	_is_enabled = true
	crosshair.enable()


## Disable shooting and hide crosshair
func disable() -> void:
	_is_enabled = false
	crosshair.disable()
