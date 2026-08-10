class_name BusyManager
extends Node2D

signal busy_started
signal busy_ended

var _has_settled := false
var _busy_nodes: Array[Node2D] = []

@onready var settle_timer: Timer = $SettleTimer


func _ready() -> void:
	EventSystem.busy.busy_started.connect(_on_busy_started)
	EventSystem.busy.busy_finished.connect(_on_busy_finished)


func reset() -> void:
	_has_settled = false
	_busy_nodes.clear()


func _on_busy_started(node: Node2D) -> void:
	if _busy_nodes.has(node):
		return

	if _busy_nodes.is_empty():
		busy_started.emit()

	_busy_nodes.append(node)


func _on_busy_finished(node: Node2D) -> void:
	if not _busy_nodes.has(node):
		return

	_busy_nodes.erase(node)

	if _busy_nodes.is_empty() and not _has_settled:
		settle_timer.start()


func _on_settle_timer_timeout() -> void:
	if not _busy_nodes.is_empty():
		return

	busy_ended.emit()
	_has_settled = true
