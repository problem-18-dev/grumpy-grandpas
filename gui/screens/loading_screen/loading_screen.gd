class_name LoadingScreen
extends CanvasLayer

signal screen_ready

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var loading_label: Label = %LoadingLabel
@onready var progress_bar: ProgressBar = %ProgressBar


func _ready() -> void:
	_animate_loading_text()
	animation_player.play(&"transition")
	await animation_player.animation_finished

	screen_ready.emit()


func set_progress(progress: float) -> void:
	progress_bar.value = progress


func finish() -> void:
	animation_player.play_backwards(&"transition")
	await animation_player.animation_finished
	queue_free()


func _animate_loading_text() -> void:
	var tween := create_tween().set_loops()
	tween.tween_method(_change_loading_dots, 1, 3, 1)


func _change_loading_dots(dots: int) -> void:
	loading_label.text = "Loading"
	loading_label.text += "".rpad(dots, ".")
