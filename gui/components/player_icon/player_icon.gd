@tool
class_name PlayerIcon
extends Control

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

@export_group("Properties")
@export var manual_gender := PlayerResource.Gender.GRANDPA
@export var manual_color := TeamResource.TeamColor.RED

@onready var foot: TextureRect = $Foot
@onready var leg: TextureRect = $Leg
@onready var head: TextureRect = $Head
@onready var body: TextureRect = $Body
@onready var hand: TextureRect = $Hand
@onready var stick: TextureRect = $Stick


func _ready() -> void:
	setup(manual_gender, TeamResource.TEAM_COLORS[manual_color])


func setup(gender: PlayerResource.Gender, color: Color) -> void:
	foot.texture = GENDER_SPRITES[gender].foot
	leg.texture = GENDER_SPRITES[gender].leg
	head.texture = GENDER_SPRITES[gender].head
	body.texture = GENDER_SPRITES[gender].body
	stick.texture = GENDER_SPRITES[gender].stick
	hand.texture = GENDER_SPRITES[gender].arm

	body.modulate = color
