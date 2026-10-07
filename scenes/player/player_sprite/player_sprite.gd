class_name PlayerSprite
extends Node2D

const GENDER_SPRITES := {
	PlayerResource.Gender.GRANDMA: {
		"foot": preload("uid://dmyyadvvs6q0q"),
		"leg": preload("uid://4hcehbouow2i"),
		"head": preload("uid://c2lunf8m1j3dt"),
		"body": preload("uid://w1dqe4ieqgyl"),
		"hand": preload("uid://dpt1iq7g4fkbo"),
		"stick": preload("uid://dr5wap7yr8vnd"),
	},
	PlayerResource.Gender.GRANDPA: {
		"foot": preload("uid://cbem3m68tko5r"),
		"leg": preload("uid://ds6oyddyfvcc6"),
		"head": preload("uid://c4ildcihg11ok"),
		"body": preload("uid://td7hdwa1u7lb"),
		"hand": preload("uid://blxw8c7m7hljd"),
		"stick": preload("uid://duc7xjifhvhho"),
	},
}

var player: Player

@onready var foot: Node2D = $Foot
@onready var head: Node2D = $Head
@onready var arm: Node2D = $Arm
@onready var foot_sprite: Sprite2D = $Foot/FootSprite
@onready var leg_sprite: Sprite2D = $LegSprite
@onready var head_sprite: Sprite2D = $Head/HeadSprite
@onready var body_sprite: Sprite2D = $BodySprite
@onready var stick_sprite: Sprite2D = $Arm/StickSprite
@onready var hand_sprite: Sprite2D = $Arm/HandSprite

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	await owner.ready
	assert(owner is Player, "PlayerSprite must be used under Player.")
	player = owner


func _physics_process(_delta: float) -> void:
	_handle_feet_rotation()
	_handle_movement_animation()


func setup(gender: PlayerResource.Gender, color: Color) -> void:
	foot_sprite.texture = GENDER_SPRITES[gender].foot
	leg_sprite.texture = GENDER_SPRITES[gender].leg
	head_sprite.texture = GENDER_SPRITES[gender].head
	body_sprite.texture = GENDER_SPRITES[gender].body
	stick_sprite.texture = GENDER_SPRITES[gender].stick
	hand_sprite.texture = GENDER_SPRITES[gender].hand

	body_sprite.modulate = color


func rotate_head(angle: float) -> void:
	head.rotation = clampf(angle, -PI / 4, PI / 4)


func flip(value: bool) -> void:
	scale.x = -0.4 if value else 0.4


func _handle_feet_rotation() -> void:
	var target := 0.0

	if player.is_on_floor():
		target = player.get_floor_normal().angle() + PI / 2.0

	foot.rotation = target * signf(scale.x)


func _handle_movement_animation() -> void:
	if player.is_on_floor() and not is_zero_approx(player.velocity.x):
		animation_player.play("walk")
		return

	animation_player.play("idle", -1, randf_range(0.9, 1.1))
