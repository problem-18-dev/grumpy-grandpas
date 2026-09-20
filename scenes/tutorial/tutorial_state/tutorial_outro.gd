extends TutorialState


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm") and not _can_continue():
		GameManager.reset()
		get_tree().change_scene_to_file(tutorial.MAIN_MENU_UID)
		return

	super(event)


func _start() -> void:
	tutorial.players_manager.deactivate_player()


func _continue() -> void:
	_announcement_pointer += 1
	tutorial.show_announcement(announcements[_announcement_pointer])


func _can_continue() -> bool:
	return _announcement_pointer < announcements.size() - 1
