class_name BusyManager
extends Node

signal busy_started
signal busy_ended

enum BusyState {
	## Watching, nothing busy observed yet.
	IDLE,
	## Busy observed, waiting for everything to be ready.
	POLLING,
	## Ready, waiting for settle_time before the cycle is declared over.
	SETTLING,
	## Cycle finished, busy_ended emitted, timers off.
	SETTLED,
	## Timers off, no signal. Nothing watched until start().
	STOPPED,
}

var _state: BusyState

@export_group("Timing")
@export var polling_time := 0.25
@export var settle_time := 0.5

@onready var polling_timer: Timer = $PollingTimer
@onready var settle_timer: Timer = $SettleTimer


func _ready() -> void:
	polling_timer.wait_time = polling_time
	settle_timer.wait_time = settle_time
	_change_state(BusyState.IDLE)


## (Re)start busy manager
func start() -> void:
	_change_state(BusyState.IDLE)


## Premature stop of busy polling and settling
func stop() -> void:
	_change_state(BusyState.STOPPED)


func is_busy() -> bool:
	return _state == BusyState.POLLING or _state == BusyState.SETTLING


func _change_state(new_state: BusyState) -> void:
	match new_state:
		BusyState.IDLE, BusyState.POLLING:
			settle_timer.stop()
			polling_timer.start()
		BusyState.SETTLING:
			settle_timer.start()
		BusyState.SETTLED:
			polling_timer.stop()
			settle_timer.stop()
			busy_ended.emit()
		BusyState.STOPPED:
			polling_timer.stop()
			settle_timer.stop()

	_state = new_state


func _check_players() -> bool:
	var players := get_tree().get_nodes_in_group("player")

	if players.is_empty():
		return true

	var all_players_ready := players.all(
		func(p: Player) -> bool:
			return not p.is_busy,
	)

	return all_players_ready


func _check_projectiles() -> bool:
	var projectiles := get_tree().get_nodes_in_group("projectile")
	return projectiles.is_empty()


func _check_explosions() -> bool:
	var explosions := get_tree().get_nodes_in_group("explosion")
	return explosions.is_empty()


func _on_polling_timer_timeout() -> void:
	var players_ready := _check_players()
	var projectiles_ready := _check_projectiles()
	var explosions_ready := _check_explosions()

	var all_ready := players_ready and projectiles_ready and explosions_ready

	match _state:
		BusyState.IDLE:
			if not all_ready:
				_change_state(BusyState.POLLING)
				busy_started.emit()
		BusyState.POLLING:
			if all_ready:
				_change_state(BusyState.SETTLING)
				return
		BusyState.SETTLING:
			if not all_ready:
				_change_state(BusyState.POLLING)


func _on_settle_timer_timeout() -> void:
	_change_state(BusyState.SETTLED)
