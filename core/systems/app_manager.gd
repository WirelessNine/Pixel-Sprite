extends Node

const UNNAMED_TITLE: String = "Unnamed %01d"

var files: Array[FileInstance]
var current_file_number: int = 0


func create_file(canvas_size: Vector2i) -> void:
	var file := FileInstance.new()

	file.title = UNNAMED_TITLE % current_file_number
	file.canvas_size = canvas_size

	current_file_number += 1

	files.append(file)

	Events.file_created.emit(file)
