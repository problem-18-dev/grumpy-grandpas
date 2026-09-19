class_name Tutorial
extends Node

const HUD_UID := "uid://c5q7bwqmijr3e"
const INVENTORY_UID := "uid://bkrmhl1oip2je"
const MAIN_MENU_UID := "uid://b2d8kklebnhfj"
const TEAM_TUTORIAL_BLUE = preload("uid://cgtof6pv3rtlo")
const TEAM_TUTORIAL_RED = preload("uid://ci6lhhlkv6opp")
const TUTORIAL_LEVEL = preload("uid://bw3v314eg0rgg")
const TUTORIAL_ANNOUNCEMENT = preload("uid://gpncyxff15bx")
const CRATE = preload("uid://cigipvuxrk2eo")
const TUTORIAL_CATALOGUE = preload("uid://c0onk6kmhoekl")

@export_group("Announcements")
@export var announcement_intro_duration := 3.0
@export var announcement_duration := 3.0

var _tutorial_level: TutorialLevel
var _is_preparing := false

@onready var hud: HUD = %HUD
@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var inventory_root: Control = %InventoryRoot
@onready var continue_label: Label = %ContinueLabel

var _announcement_pointer := 0
var _announcements: Array = []

@onready var busy_manager: BusyManager = %BusyManager
@onready var players_manager: PlayersManager = %PlayersManager
@onready var pickuppable_manager: PickuppableManager = %PickuppableManager
@onready var tutorial_manager: TutorialManager = %TutorialManager


func _ready() -> void:
	_prepare()


func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	if event.is_action_pressed("debug_quit"):
		get_tree().change_scene_to_file(MAIN_MENU_UID)

	var can_continue := _can_continue()

	if event.is_action_pressed("confirm") and can_continue:
		_continue()
		return

	if can_continue:
		return

	tutorial_manager.record_key_event(event)


func _prepare() -> void:
	if _is_preparing:
		return
	_is_preparing = true

	GamePresets.load_preset(GamePresets.Preset.TUTORIAL)

	_clear_entities()
	await _load_level()
	_load_systems()
	_start_tutorial()

	_is_preparing = false


func _clear_entities() -> void:
	for child: Node2D in entity_root.get_children():
		child.queue_free()


func _load_level() -> void:
	if _tutorial_level:
		_tutorial_level.queue_free()
		_tutorial_level = null
		await get_tree().process_frame

	var tutorial_level: TutorialLevel = TUTORIAL_LEVEL.instantiate()
	_tutorial_level = tutorial_level
	_tutorial_level.projectile_exited.connect(_on_projectile_exited)
	level_root.add_child(_tutorial_level)


func _load_systems() -> void:
	busy_manager.reset()
	players_manager.reset()


func _start_tutorial() -> void:
	var spawn_points := _tutorial_level.get_spawn_points()
	players_manager.spawn_players(spawn_points)
	tutorial_manager.start()


func _continue() -> void:
	_announcement_pointer += 1

	if _announcement_pointer >= _announcements.size():
		if tutorial_manager.current_phase == TutorialManager.Phase.OUTRO:
			_return_to_main_menu()
			return

		tutorial_manager.next_phase()
		return

	_announcement_pointer = clampi(_announcement_pointer, 0, _announcements.size() - 1)
	hud.set_message(_announcements[_announcement_pointer])

	if _announcement_pointer == _announcements.size() - 1:
		continue_label.hide()
		_activate_player()


func _start_announcements(phase: TutorialManager.Phase) -> void:
	_announcements = TUTORIAL_ANNOUNCEMENT.get_announcements(phase)
	hud.set_message(_announcements[0])
	_announcement_pointer = 0

	if _can_continue():
		players_manager.deactivate_player()
		continue_label.show()
		return

	continue_label.hide()
	_activate_player()


func _can_continue() -> bool:
	# Intro and outro are always just text.
	if tutorial_manager.current_phase in [TutorialManager.Phase.INTRO, TutorialManager.Phase.OUTRO]:
		return true

	return _announcements.size() > 1 and _announcement_pointer < _announcements.size() - 1


func _return_to_main_menu() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file(MAIN_MENU_UID)


func _activate_player() -> void:
	if players_manager.active_player:
		return

	players_manager.activate_player()


func _lower_players_health() -> void:
	for player: Player in get_tree().get_nodes_in_group("players"):
		if player.team.get_id() != TEAM_TUTORIAL_RED.get_id():
			continue

		player.health.health = 100
		player.health.take_health(99)


func _on_pickuppable_manager_picked_up(by: Player, type: PickuppableResource.Type) -> void:
	players_manager.unlock_item(by, type)
	tutorial_manager.next_phase()


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


func _on_tutorial_manager_phase_started(phase: TutorialManager.Phase) -> void:
	tutorial_manager.initial_phase = phase

	_start_announcements(phase)

	match phase:
		TutorialManager.Phase.PICK_UP:
			await pickuppable_manager.spawn(CRATE, _tutorial_level.get_pickuppable_spawn())
		TutorialManager.Phase.ENEMY_DEATH:
			_lower_players_health()


func _on_busy_manager_busy_ended() -> void:
	await players_manager.damage_players()
	await players_manager.kill_marked_players()

	if tutorial_manager.current_phase == TutorialManager.Phase.SHOOT:
		tutorial_manager.next_phase()

	_prepare()


func _on_projectile_exited() -> void:
	_prepare()


func _on_players_manager_player_died(player: Player) -> void:
	if (
		tutorial_manager.current_phase == TutorialManager.Phase.ENEMY_DEATH
		and player.team.get_id() == TEAM_TUTORIAL_RED.get_id()
	):
		tutorial_manager.next_phase()
		return
