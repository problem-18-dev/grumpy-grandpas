extends TutorialState


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm") and not _can_continue():
		_next_phase()
		return

	super(event)


func _start() -> void:
	pass


func _continue() -> void:
	_announcement_pointer += 1
	tutorial.show_announcement(announcements[_announcement_pointer])


func _can_continue() -> bool:
	return _announcement_pointer < announcements.size() - 1
