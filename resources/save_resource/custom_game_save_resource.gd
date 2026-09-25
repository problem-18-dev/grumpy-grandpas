class_name CustomGameSaveResource
extends Resource

const SAVE_PATH := "user://custom_game.res"

@export var teams: Array[TeamResource]
@export var catalogue: CatalogueResource
@export var level: String
