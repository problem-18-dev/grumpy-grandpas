class_name BusinessManager
extends Node2D

signal business_started
signal business_ended

var _busy_nodes: Array[Node2D] = []


func _init() -> void:
	EventSystem.business.busy_started.connect(_on_busy_started)
	EventSystem.business.busy_finished.connect(_on_busy_finished)


func _on_busy_started(node: Node2D) -> void:
	if _busy_nodes.has(node):
		return

	if _busy_nodes.is_empty():
		business_started.emit()

	_busy_nodes.append(node)


func _on_busy_finished(node: Node2D) -> void:
	if not _busy_nodes.has(node):
		return

	_busy_nodes.erase(node)

	if _busy_nodes.is_empty():
		business_ended.emit()
