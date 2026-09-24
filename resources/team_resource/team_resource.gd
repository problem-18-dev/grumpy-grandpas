class_name TeamResource
extends Resource

enum CPUDifficulty {
	EASY,
	MEDIUM,
	HARD,
}

enum TeamColor {
	RED,
	BLUE,
	GREEN,
	YELLOW,
}

const TEAM_COLORS := {
	TeamColor.RED: Color(1.0, 0.424, 0.478, 1.0),
	TeamColor.BLUE: Color(0.267, 0.553, 0.906, 1.0),
	TeamColor.GREEN: Color(0.169, 0.859, 0.447, 1.0),
	TeamColor.YELLOW: Color(1.0, 0.922, 0.2, 1.0),
}


@export_group("Properties")
@export var name := ""
@export var color: TeamColor = TeamColor.RED
@export_group("Players")
@export var player_health := 100
@export var player_resources: Array[PlayerResource]
@export_group("Inventory")
@export var locked_items: Array[ItemResource]
@export_group("CPU")
@export var is_cpu: bool
@export var cpu_difficulty := CPUDifficulty.EASY

var _active_players: Array[Player]


func get_id() -> String:
	return name.strip_edges().to_lower()


func get_players() -> Array[Player]:
	return _active_players


func add_player(player: Player) -> void:
	_active_players.append(player)


func current_player() -> Player:
	return _active_players.front()


func kill_player(player: Player) -> void:
	_active_players.erase(player)


func next_player(after: Player) -> void:
	if _active_players.front() == after:
		return

	_active_players.push_back(_active_players.pop_front())


func has_lost() -> bool:
	return _active_players.is_empty()


func unlock_item(item: ItemResource) -> void:
	locked_items.erase(item)


func get_locked_items() -> Array[ItemResource]:
	return locked_items


func get_color() -> Color:
	return TEAM_COLORS[color]
