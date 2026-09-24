@tool
class_name InventoryPanel
extends Panel

signal item_selected(item: ItemResource)
signal item_hovered(hover: bool, item: ItemResource)

enum Section {
	WEAPONS,
	TOOLS,
}

const INVENTORY_ITEM_SECTION := preload("uid://cr2l1rgtsqc3e")
const SECTION_TITLES := { Section.WEAPONS: "Weapons", Section.TOOLS: "Tools" }

var _sections: Dictionary[Section, InventoryItemSection]

@onready var content_container: HBoxContainer = $MarginContainer/ContentContainer


func add_item(item: ItemResource, section: Section) -> Button:
	var button := _get_or_add_section(section).add_item(item.name)
	button.pressed.connect(item_selected.emit.bind(item))
	button.mouse_entered.connect(item_hovered.emit.bind(true, item))
	button.mouse_exited.connect(item_hovered.emit.bind(false, item))
	return button


func _get_or_add_section(section: Section) -> InventoryItemSection:
	if _sections.has(section):
		return _sections.get(section)

	var item_section: InventoryItemSection = INVENTORY_ITEM_SECTION.instantiate()
	item_section.title = SECTION_TITLES[section]
	content_container.add_child(item_section)

	_sections.set(section, item_section)
	return item_section
