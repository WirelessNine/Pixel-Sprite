extends Node

signal file_created(file: FileInstance)
signal palette_selected(new_palette: Texture2D)

signal create_file_requested
signal open_file_requested
signal save_file_requested

const UNNAMED_TITLE: String = "Unnamed %01d"

var files: Array[FileInstance]
var current_file_number: int = 0

var current_file: FileInstance


func _ready() -> void:
	_handle_scale()


func create_file(canvas_size: Vector2i) -> void:
	var file := FileInstance.new()

	file.title = UNNAMED_TITLE % current_file_number
	file.canvas_size = canvas_size

	file.setup_file()

	current_file_number += 1

	files.append(file)

	AppManager.file_created.emit(file)


func load_image(texture: Texture2D, path: String) -> void:
	var file := FileInstance.new()

	file.title = path.get_file().get_basename()
	file.canvas_size = texture.get_size()
	file.file_path = path

	file.setup_file()

	var rect := Rect2i(Vector2i.ZERO, file.canvas_size)
	file.current_layer.texture.blit_rect(rect, texture)

	files.append(file)

	AppManager.file_created.emit(file)


func _handle_scale() -> void:
	var window_size_y: int = get_window().size.y

	if window_size_y >= 1200:
		get_window().content_scale_factor = 5.0
	else:
		get_window().content_scale_factor = 2.0
