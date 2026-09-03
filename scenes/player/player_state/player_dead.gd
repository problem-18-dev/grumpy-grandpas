extends PlayerState

const BED := preload("uid://dt41u72nlmr4c")
const PLAYER_EXPLOSION = preload("uid://d0al511wp4v17")

@export_group("Properties")
@export var pre_death_timer := 3.0
@export var post_death_timer := 1.5


func enter(_data := { }) -> void:
	player.reset()
	_die()


func _physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	player.move_and_slide()


func _die() -> void:
	Debug.log("%s has died" % player.name)
	player.name_label.text = "%s (dead)" % player.name

	# TODO: replace this with animation
	await get_tree().create_timer(pre_death_timer).timeout

	_disable_player()
	_explode()
	_spawn_bed()
	_cleanup()


func _explode() -> void:
	Utils.create_explosion(PLAYER_EXPLOSION, player.global_position)


func _spawn_bed() -> void:
	var bed: Node2D = BED.instantiate()
	player.add_child(bed)


func _disable_player() -> void:
	player.sprite.hide()
	player.hurtbox.enabled = false
	player.collision_layer = 0 # Disable all layers


func _cleanup() -> void:
	await get_tree().create_timer(post_death_timer).timeout
	player.died.emit(player)
