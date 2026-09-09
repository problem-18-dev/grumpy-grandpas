class_name Game
extends Node

enum Level {
	MATCH,
}

const HUD_UID := "uid://c5q7bwqmijr3e"
const INVENTORY_UID := "uid://bkrmhl1oip2je"

@export var initial_level := Level.MATCH

var _level_paths: Dictionary[Level, String] = { Level.MATCH: "uid://cd2ib37t0cgmf" }
var _current_level: BaseLevel
var _current_hud: HUD

@onready var level_root: Node2D = %LevelRoot
@onready var hud_root: Control = %HUDRoot
@onready var inventory_root: Control = %InventoryRoot

@onready var busy_manager: BusyManager = %BusyManager
@onready var turn_manager: TurnManager = %TurnManager
@onready var players_manager: PlayersManager = %PlayersManager
@onready var pickuppable_manager: PickuppableManager = %PickuppableManager


func _ready() -> void:
	await load_level(initial_level)
	_start_level()


func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	if event.is_action_pressed("debug_quit"):
		get_tree().quit()


func load_level(new_scene: Level) -> void:
	if _current_level:
		_current_level.queue_free()
		_current_level = null
		await get_tree().process_frame

	_current_level = load(_level_paths[new_scene]).instantiate()
	_current_level.projectile_exited.connect(_on_projectile_exited)
	level_root.add_child(_current_level)

	await get_tree().process_frame

	load_systems()
	load_hud()


func load_systems() -> void:
	busy_manager.reset()
	turn_manager.reset()
	players_manager.reset()
	pickuppable_manager.setup(_current_level.get_spawn_follow())


func load_hud() -> void:
	var hud: HUD = load(HUD_UID).instantiate()
	hud_root.add_child(hud)
	_current_hud = hud


func _start_level() -> void:
	var spawn_points := _current_level.get_spawn_points()
	players_manager.spawn_players(spawn_points)
	players_manager.activate_player()
	turn_manager.start_turn()


func _announce_winner() -> void:
	var winner := players_manager.get_winner()

	if winner:
		players_manager.show_team(winner)
		_current_hud.set_message("%s has won!" % winner.name)
		return

	_current_hud.set_message("No winners this time!")


func _continue() -> void:
	if players_manager.teams.size() <= 1:
		_announce_winner()
		return

	busy_manager.reset()
	await pickuppable_manager.attempt_spawn()
	players_manager.next_team()
	players_manager.activate_player()
	turn_manager.start_turn()


func _on_pickuppable_manager_picked_up(by: Player, type: PickuppableResource.Type) -> void:
	players_manager.unlock_item(by, type)


func _on_busy_manager_busy_started() -> void:
	print("Busy started")
	turn_manager.hold_turn()


func _on_busy_manager_busy_ended() -> void:
	print("Busy ended")
	turn_manager.finish_turn()


func _on_turn_manager_time_changed(time: int) -> void:
	_current_hud.set_turn_timer(time)


func _on_turn_manager_transition_finished() -> void:
	_current_level.cleanup()
	await players_manager.damage_players()
	await players_manager.kill_marked_players()
	_continue()


func _on_turn_manager_turn_ended() -> void:
	players_manager.deactivate_player()


func _on_players_manager_inventory_requested(
	locked_items: Array[ItemResource],
	current_item: ItemResource,
) -> void:
	if busy_manager.is_busy():
		return

	players_manager.deactivate_player()
	var inventory: Inventory = load(INVENTORY_UID).instantiate()
	inventory_root.add_child(inventory)
	inventory.closed.connect(_on_inventory_closed)
	inventory.open(locked_items, current_item)


func _on_inventory_closed(new_item: ItemResource = null) -> void:
	players_manager.activate_player()

	if new_item:
		players_manager.player_equip(new_item)


func _on_projectile_exited() -> void:
	turn_manager.finish_turn()
