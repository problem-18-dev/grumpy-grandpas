class_name PlayerResource
extends Resource

enum Gender {
	GRANDPA = 0,
	GRANDMA = 1,
}

## Pre-made names given to new players, can be changed later by the user
const GRANDPA_NAMES: Array[String] = [
	"Arthur",
	"Poe",
	"Nick",
	"Walter",
	"Harold",
	"Bernard",
	"Gus",
	"Stanley",
	"Mabel",
]

const GRANDMA_NAMES: Array[String] = [
	"Luna",
	"Edna",
	"Doris",
	"Melissa",
	"Monica",
	"Lilly",
	"Sam",
	"Maxine",
	"Anna",
]

@export_group("Properties")
@export var name: String
@export var health := 100
@export var gender := Gender.GRANDPA
