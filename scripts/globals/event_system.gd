extends Node

var camera := Camera.new()
var business := Business.new()


class Camera:
	signal request_follow(target: Node2D, priority: GameCamera.Priority)
	signal revoke_follow(target: Node2D)


class Business:
	signal busy_started(node: Node2D)
	signal busy_finished(node: Node2D)
