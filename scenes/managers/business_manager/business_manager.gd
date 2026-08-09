class_name BusinessManager
extends Node2D

signal business_started
signal business_ended

@export_group("Properties")
@export var settle_time := 0.5

var _busy_nodes: Array[Node2D] = []
var _is_settled := true

@onready var settle_timer: Timer = $SettleTimer


func _init() -> void:
	EventSystem.business.busy_started.connect(_on_busy_started)
	EventSystem.business.busy_finished.connect(_on_busy_finished)


func _on_busy_started(node: Node2D) -> void:
	if _busy_nodes.has(node):
		return

	settle_timer.stop()
	_busy_nodes.append(node)

	if _is_settled:
		_is_settled = false
		business_started.emit()


func _on_busy_finished(node: Node2D) -> void:
	if not _busy_nodes.has(node):
		return

	_busy_nodes.erase(node)

	if _busy_nodes.is_empty():
		settle_timer.start(settle_time)


func _on_timer_timeout() -> void:
	if not _busy_nodes.is_empty():
		return

	_is_settled = true
	business_ended.emit()
