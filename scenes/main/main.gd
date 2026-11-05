extends Control

const HOME_TITLE: String = "Home"
const UNNAMED_TITLE: String = "Unnamed %01d"

@onready var menu_bar: MenuBar = %MenuBar

@onready var options_menu: PopupMenu = %Options

@onready var tabs: TabBar = %Tabs

@onready var home_screen: PanelContainer = %HomeScreen
@onready var draw_editor: DrawEditor = %DrawEditor

@onready var background_rect: ColorRect = $Dialogs/Background

@onready var file_dialog: FileDialog = %FileDialog
@onready var save_dialog: FileDialog = %SaveDialog

var current_file_number: int = 0


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("14182e"))
	OS.request_permissions()

	MenuManager.set_background(background_rect)

	_connect_signals()

	_create_home_tab()


func _connect_signals() -> void:
	tabs.tab_changed.connect(_on_tab_changed)

	AppManager.file_created.connect(_on_file_created)
	AppManager.open_file_requested.connect(file_dialog.popup_centered)
	AppManager.save_file_requested.connect(_on_save_requested)


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


func _on_tab_changed(tab: int) -> void:
	var title: String = tabs.get_tab_title(tab)

	if title == HOME_TITLE:
		_show_home_screen()
		AppManager.current_file = null
	else:
		_show_draw_editor()
		var meta: Variant = tabs.get_tab_metadata(tab)

		draw_editor.update_editor(meta)
		AppManager.current_file = meta


func _on_file_created(file: FileInstance) -> void:
	tabs.add_tab(file.title)

	var id: int = tabs.tab_count - 1

	tabs.set_tab_metadata(id, file)
	tabs.current_tab = id


func _on_save_requested() -> void:
	var file: FileInstance = AppManager.current_file

	if file == null:
		return

	if file.file_path:
		file.get_as_image().save_png(file.file_path)
	else:
		save_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
	var image := Image.load_from_file(path)

	if not image:
		return

	var texture := ImageTexture.create_from_image(image)

	AppManager.load_image(texture, path)


func _on_save_dialog_file_selected(path: String) -> void:
	if AppManager.current_file == null:
		return

	var file: FileInstance = AppManager.current_file
	file.get_as_image().save_png(path)
	file.file_path = path
	file.title = path.get_file().get_basename()

	for x: int in tabs.tab_count:
		var meta: Variant = tabs.get_tab_metadata(x)

		if meta == file:
			tabs.set_tab_title(x, meta.title)
			return


func _on_tabs_tab_close_pressed(tab: int) -> void:
	var file: FileInstance = AppManager.current_file

	if file == null:
		return

	if file.file_path:
		file.get_as_image().save_png(file.file_path)
		tabs.remove_tab(tab)
	else:
		save_dialog.popup_centered()
