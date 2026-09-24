class_name PlayerResource
extends Resource

## Pre-made names given to new players, can be changed later by the user
const RANDOM_NAMES: Array[String] = [
	"Arthur", "Luna", "Poe", "Nick", "Walter", "Harold",
	"Bernard", "Gus", "Stanley", "Mabel", "Edna", "Doris",
]

@export_group("Properties")
@export var name: String
@export var health := 100
