extends Node

var camera := Camera.new()
var busy := Busy.new()


class Camera:
	signal request_follow(target: Node2D, priority: GameCamera.Priority)
	signal revoke_follow(target: Node2D)


class Busy:
	signal busy_started(node: Node2D)
	signal busy_finished(node: Node2D)
