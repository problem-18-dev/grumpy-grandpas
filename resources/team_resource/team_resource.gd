class_name TeamResource
extends Resource

@export_group("Properties")
@export var name := "Team One"
@export var color := Color(1.0, 0.494, 0.427, 1.0)
@export_group("Players")
@export var player_resources: Array[PlayerResource]
@export_group("Inventory")
@export var locked_items: Array[ItemResource]

var _active_players: Array[Player]


func get_players() -> Array[Player]:
	return _active_players


func add_player(player: Player) -> void:
	_active_players.append(player)


func current_player() -> Player:
	return _active_players.front()


func kill_player(player: Player) -> void:
	_active_players.erase(player)


func next_player(after: Player) -> void:
	if _active_players.front() != after:
		return

	_active_players.push_back(_active_players.pop_front())


func has_lost() -> bool:
	return _active_players.is_empty()


func unlock_item(item: ItemResource) -> void:
	locked_items.erase(item)


func get_locked_items() -> Array[ItemResource]:
	return locked_items
