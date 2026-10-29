extends Control

const HOME_TITLE: String = "Home"
const UNNAMED_TITLE: String = "Unnamed %01d"

@onready var menu_bar: MenuBar = %MenuBar

@onready var file_menu: PopupMenu = %File
@onready var edit_menu: PopupMenu = %Edit
@onready var sprite_menu: PopupMenu = %Sprite
@onready var frame_menu: PopupMenu = %Frame
@onready var view_menu: PopupMenu = %View

@onready var tabs: TabBar = %Tabs

@onready var home_screen: PanelContainer = %HomeScreen
@onready var draw_editor: DrawEditor = %DrawEditor

@onready var background_rect: ColorRect = $Dialogs/Background

var current_file_number: int = 0


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("14182e"))
	OS.request_permissions()

	MenuManager.set_background(background_rect)

	_connect_signals()

	_create_home_tab()
	_create_edit_menu_items()


func _connect_signals() -> void:
	tabs.tab_changed.connect(_on_tab_changed)

	Events.file_created.connect(_on_file_created)


func _show_home_screen() -> void:
	home_screen.show()
	draw_editor.hide()


func _show_draw_editor() -> void:
	draw_editor.show()
	home_screen.hide()


func _create_home_tab() -> void:
	for x: int in tabs.tab_count:
		if tabs.get_tab_title(x) == HOME_TITLE:
			return

	tabs.add_tab(HOME_TITLE)
	var tab_id: int = tabs.tab_count - 1

	tabs.move_tab(tab_id, 0)


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


func _on_tab_changed(tab: int) -> void:
	var title: String = tabs.get_tab_title(tab)

	if title == HOME_TITLE:
		_show_home_screen()
	else:
		_show_draw_editor()
		draw_editor.update_editor(tabs.get_tab_metadata(tab))


func _on_file_created(file: FileInstance) -> void:
	tabs.add_tab(file.title)

	var id: int = tabs.tab_count - 1

	tabs.set_tab_metadata(id, file)
	tabs.current_tab = id
