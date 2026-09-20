extends Node

var blocked: Array[String] = []


func allow_all() -> void:
	blocked.clear()


func allow_some(inputs: Array) -> void:
	for input: String in inputs:
		if blocked.has(input):
			blocked.erase(input)


func allow(input: String) -> void:
	blocked.erase(input)


func block_all() -> void:
	blocked = ["move_left", "move_right", "up", "down", "jump", "shoot", "inventory", "camera"]


func block(input: String) -> void:
	if blocked.has(input):
		return

	blocked.append(input)


func has(input: String) -> bool:
	return blocked.has(input)


func has_multiple(inputs: Array[String]) -> bool:
	for input: String in inputs:
		if blocked.has(input):
			return true

	return false
