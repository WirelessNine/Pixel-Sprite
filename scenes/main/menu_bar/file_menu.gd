extends PopupMenu


func _ready() -> void:
	id_pressed.connect(_on_id_pressed)

	create_items()


func create_items() -> void:
	add_item("New", 0)
	add_item("Open", 1)

	add_separator()

	add_item("Save", 2)
	add_item("Close", 3)


func _on_id_pressed(id: int) -> void:
	match id:
		0:
			AppManager.create_file_requested.emit()
		1:
			AppManager.open_file_requested.emit()
		2:
			AppManager.save_file_requested.emit()
