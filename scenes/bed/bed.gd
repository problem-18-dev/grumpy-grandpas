class_name Bed
extends Node2D

const GRANDMA_BED_UID := "uid://c83nxotgh647t"
const GRANDPA_BED_UID := "uid://desicq2abuxra"

@onready var sprite: Sprite2D = $Sprite2D


func setup(gender: PlayerResource.Gender, color: Color) -> void:
	var bed_uid := GRANDPA_BED_UID if gender == PlayerResource.Gender.GRANDPA else GRANDMA_BED_UID
	sprite.texture = load(bed_uid)
	sprite.modulate = color
