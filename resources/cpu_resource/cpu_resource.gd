class_name CPUResource
extends Resource

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
}

@export var difficulty := Difficulty.EASY


## Returns angle range to add to CPU's final shot result
func get_angle_range() -> float:
	match difficulty:
		Difficulty.MEDIUM:
			return deg_to_rad(20)
		Difficulty.HARD:
			return deg_to_rad(10)
		_:
			return deg_to_rad(30)
