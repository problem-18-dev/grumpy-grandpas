@tool
class_name PlayerSprite
extends Node2D

const GENDER_SPRITES := {
	PlayerResource.Gender.GRANDMA: {
		"foot": preload("uid://ci6lv3oxer4rl"),
		"leg": preload("uid://bsmychmwlhy21"),
		"head": preload("uid://cosdsctdfc8wg"),
		"body": preload("uid://bol6nclry3c1n"),
		"arm": preload("uid://3pc2kow8trq3"),
		"stick": preload("uid://bnwcx2373y3gr"),
	},
	PlayerResource.Gender.GRANDPA: {
		"foot": preload("uid://brc6nvf8lkc8g"),
		"leg": preload("uid://d38mbcvu6cy77"),
		"head": preload("uid://c04o52lluftcm"),
		"body": preload("uid://cr4pf6lpd8uup"),
		"arm": preload("uid://c221t012t3gdk"),
		"stick": preload("uid://5b8w8qsvu6nu"),
	},
}

@export_group("Manual")
@export var manual_gender: PlayerResource.Gender
@export var manual_color: TeamResource.TeamColor

var player: Player

@onready var foot: Node2D = $Foot
@onready var head: Node2D = $Head
@onready var arm: Node2D = $Arm
@onready var extra: Node2D = $Extra
@onready var foot_sprite: Sprite2D = $Foot/FootSprite
@onready var leg_sprite: Sprite2D = $LegSprite
@onready var head_sprite: Sprite2D = $Head/HeadSprite
@onready var body_sprite: Sprite2D = $BodySprite
@onready var stick_sprite: Sprite2D = $Arm/StickSprite
@onready var hand_sprite: Sprite2D = $Arm/HandSprite

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint() and manual_gender and manual_color:
		setup(manual_gender, TeamResource.TEAM_COLORS[manual_color])

	if not owner:
		return

	await owner.ready
	assert(owner is Player, "PlayerSprite must be used under Player.")
	player = owner


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	_handle_feet_rotation()
	_handle_movement_animation()


func setup(gender: PlayerResource.Gender, team_color: Color) -> void:
	foot_sprite.texture = GENDER_SPRITES[gender].foot
	leg_sprite.texture = GENDER_SPRITES[gender].leg
	head_sprite.texture = GENDER_SPRITES[gender].head
	body_sprite.texture = GENDER_SPRITES[gender].body
	stick_sprite.texture = GENDER_SPRITES[gender].stick
	hand_sprite.texture = GENDER_SPRITES[gender].arm

	body_sprite.modulate = team_color


func rotate_head(angle: float) -> void:
	head.rotation = clampf(angle, -PI / 4, PI / 4)


func flip(value: bool) -> void:
	scale.x = -0.25 if value else 0.25


func toggle_arm(value: bool) -> void:
	arm.visible = value


func set_extra(extra_to_add: Node2D) -> void:
	extra.add_child(extra_to_add)


func clear_extra() -> void:
	for child in extra.get_children():
		child.queue_free()


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
