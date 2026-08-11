extends Node

var camera := Camera.new()
var busy := Busy.new()


class Camera:
	signal request_follow(target: Node2D, priority: GameCamera.Priority, zoom: GameCamera.Zoom)
	signal revoke_follow(target: Node2D)


class Busy:
	## Add node to list of busy events in the round
	signal busy_started(node: Node2D)
	## Remove node from list of busy events in the round
	signal busy_finished(node: Node2D)
