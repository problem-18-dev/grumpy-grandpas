class_name PlayerState
extends State

const IDLE = "Idle"
const WALK = "Walk"
const AIR = "Air"

var player: Player


func _ready() -> void:
	assert(owner is Player, "Player state not owned by player")
	player = owner


func _apply_gravity(delta: float) -> void:
	player.velocity.y += player.get_gravity().y * delta


## Check after last move_and_slide call in case floor disappeared and we're in AIR
func _check_floor() -> void:
	if player.is_on_floor():
		return

	finished.emit(PlayerState.AIR)
