extends TutorialState

@onready var busy_manager: BusyManager = %BusyManager
@onready var players_manager: PlayersManager = %PlayersManager


func enter(data := { }) -> void:
	super(data)
	tutorial.lower_enemy_health()


func exit() -> void:
	super()

	if busy_manager.busy_ended.is_connected(_on_busy_manager_busy_ended):
		busy_manager.busy_ended.disconnect(_on_busy_manager_busy_ended)
	busy_manager.stop()

	if players_manager.player_died.is_connected(_on_players_manager_player_died):
		players_manager.player_died.disconnect(_on_players_manager_player_died)


func _start() -> void:
	super()
	InputGate.allow_all()

	busy_manager.start()

	if not busy_manager.busy_ended.is_connected(_on_busy_manager_busy_ended):
		busy_manager.busy_ended.connect(_on_busy_manager_busy_ended, CONNECT_ONE_SHOT)

	if not players_manager.player_died.is_connected(_on_players_manager_player_died):
		players_manager.player_died.connect(_on_players_manager_player_died, CONNECT_ONE_SHOT)


func _on_busy_manager_busy_ended() -> void:
	if tutorial.players_manager.players_to_damage.is_empty():
		_next_phase()
		return

	await tutorial.players_manager.damage_players()
	await tutorial.players_manager.kill_marked_players()


func _on_players_manager_player_died(player: Player) -> void:
	if player.team.get_id() == tutorial.TEAM_TUTORIAL_RED.get_id():
		_next_phase()
