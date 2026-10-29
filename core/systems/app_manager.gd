extends Node

const UNNAMED_TITLE: String = "Unnamed %01d"

var files: Array[FileInstance]
var current_file_number: int = 0


func _ready() -> void:
	_handle_scale()


func create_file(canvas_size: Vector2i) -> void:
	var file := FileInstance.new()

	file.title = UNNAMED_TITLE % current_file_number
	file.canvas_size = canvas_size

	file.setup_file()

	current_file_number += 1

	files.append(file)

	Events.file_created.emit(file)


func _handle_scale() -> void:
	var window_size_y: int = get_window().size.y

	if window_size_y >= 1200:
		get_window().content_scale_factor = 5.0
	else:
		get_window().content_scale_factor = 2.0
