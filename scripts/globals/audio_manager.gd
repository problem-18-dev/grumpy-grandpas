extends Node

enum Bus {
	MASTER,
	SFX,
	MUSIC,
	GUI,
}

const BUS := { Bus.MASTER: "Master", Bus.SFX: "SFX", Bus.MUSIC: "Music", Bus.GUI: "GUI" }


func play_sfx(stream: AudioStream) -> AudioStreamPlayer:
	return _play(stream, Bus.SFX, randf_range(0.9, 1.1))


func play_gui(stream: AudioStream) -> AudioStreamPlayer:
	return _play(stream, Bus.GUI, randf_range(0.85, 1.15))


func _play(stream: AudioStream, bus: Bus, pitch_scale := 1.0) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = BUS[bus]
	player.stream = stream
	player.pitch_scale = pitch_scale
	player.finished.connect(_on_player_finished.bind(player))
	add_child.call_deferred(player)
	player.play.call_deferred()
	return player


func _on_player_finished(player: AudioStreamPlayer) -> void:
	player.queue_free()
