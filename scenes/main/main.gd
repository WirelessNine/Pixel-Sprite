extends Control

@onready var menu_bar: MenuBar = %MenuBar

@onready var file_menu: PopupMenu = %File
@onready var edit_menu: PopupMenu = %Edit
@onready var sprite_menu: PopupMenu = %Sprite
@onready var frame_menu: PopupMenu = %Frame
@onready var view_menu: PopupMenu = %View

@onready var tabs: TabBar = %Tabs


func _ready() -> void:
	_handle_scale()

	_create_home_tab()
	_create_file_menu_items()
	_create_edit_menu_items()


func _handle_scale() -> void:
	var window_size_y: int = get_window().size.y

	if window_size_y >= 1200:
		get_window().content_scale_factor = 5.0
	else:
		get_window().content_scale_factor = 2.0


func _create_home_tab() -> void:
	for x: int in tabs.tab_count:
		if tabs.get_tab_title(x) == "Home":
			return

	tabs.add_tab("Home")
	var tab_id: int = tabs.tab_count - 1

	tabs.move_tab(tab_id, 0)


func _create_file_menu_items() -> void:
	file_menu.add_item("New")
	file_menu.add_item("Open")

	file_menu.add_separator()

	file_menu.add_item("Save")
	file_menu.add_item("Save As")
	file_menu.add_item("Close")


func _create_edit_menu_items() -> void:
	edit_menu.add_item("Undo")
	edit_menu.add_item("Redo")

	edit_menu.add_separator()

	edit_menu.add_item("Cut")
	edit_menu.add_item("Copy")
	edit_menu.add_item("Paste")
	edit_menu.add_item("Delete")

	edit_menu.add_separator()

	var rotate_submenu := PopupMenu.new()

	rotate_submenu.add_item("180°")
	rotate_submenu.add_item("90° CW")
	rotate_submenu.add_item("90° CCW")

	edit_menu.add_child(rotate_submenu)
	edit_menu.add_submenu_node_item("Rotate", rotate_submenu)

	edit_menu.add_item("Flip Horizontal")
	edit_menu.add_item("Flip Vertical")

	edit_menu.add_separator()

	edit_menu.add_item("Settings")
