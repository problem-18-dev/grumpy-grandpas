extends HBoxContainer

const QUICKPLAY_CATALOGUE = preload("uid://bl3irmmkftpba")

var _catalogue: CatalogueResource = QUICKPLAY_CATALOGUE.duplicate_deep()

@onready var weapons_list: ItemList = %WeaponsList
@onready var tools_list: ItemList = %ToolsList


func _ready() -> void:
	var weapons_without_default := QUICKPLAY_CATALOGUE.weapons.filter(
		func(w: ItemResource) -> bool:
			return w != QUICKPLAY_CATALOGUE.default_weapon,
	)
	_update_list(weapons_list, weapons_without_default)
	_update_list(tools_list, QUICKPLAY_CATALOGUE.tools)


func _update_list(list: ItemList, items: Array[ItemResource]) -> void:
	for item in items:
		var index := list.add_item(item.name)
		list.set_item_metadata(index, item)
		list.select(index, false)


func _update_catalogue(
	list: ItemList,
	catalogue_list: Array[ItemResource],
	index: int,
	selected: bool,
) -> void:
	var item: ItemResource = list.get_item_metadata(index)

	if not selected:
		catalogue_list.erase(item)
	else:
		catalogue_list.append(item)

	GameManager.set_catalogue(_catalogue)


func _on_tools_list_multi_selected(index: int, selected: bool) -> void:
	_update_catalogue(tools_list, _catalogue.tools, index, selected)


func _on_weapons_list_multi_selected(index: int, selected: bool) -> void:
	_update_catalogue(weapons_list, _catalogue.weapons, index, selected)
