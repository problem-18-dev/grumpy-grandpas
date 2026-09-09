class_name BusyManager
extends Node

signal busy_started
signal busy_ended

var _has_settled := false
var _busy_nodes: Array[Node] = []

@onready var settle_timer: Timer = $SettleTimer


func _ready() -> void:
	EventSystem.busy.busy_started.connect(_on_busy_started)
	EventSystem.busy.busy_finished.connect(_on_busy_finished)


func reset() -> void:
	_has_settled = false
	_busy_nodes.clear()
	settle_timer.stop()


func is_busy() -> bool:
	return not _busy_nodes.is_empty() or not settle_timer.is_stopped()


func _on_busy_started(node: Node) -> void:
	if _busy_nodes.has(node):
		return

	# If no busy nodes, settling hasn't triggered and hasn't settled, only then do we announce.
	if _busy_nodes.is_empty() and settle_timer.is_stopped() and not _has_settled:
		busy_started.emit()

	_busy_nodes.append(node)


func _on_busy_finished(node: Node) -> void:
	if not _busy_nodes.has(node):
		return

	_busy_nodes.erase(node)

	if _busy_nodes.is_empty() and not _has_settled:
		settle_timer.start()


func _on_settle_timer_timeout() -> void:
	if not _busy_nodes.is_empty():
		return

	_has_settled = true
	busy_ended.emit()
