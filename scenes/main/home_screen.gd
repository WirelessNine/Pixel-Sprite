extends PanelContainer


func _on_create_file_pressed() -> void:
	MenuManager.open_menu("create_file")


func _on_open_file_pressed() -> void:
	AppManager.open_file_requested.emit()
