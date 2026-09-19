class_name TutorialAnnouncementResource
extends AnnouncementResource

@export var announcements: Dictionary[TutorialManager.Phase, Array]


func get_announcements(phase: TutorialManager.Phase) -> Array:
	return announcements[phase]
