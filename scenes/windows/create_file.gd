extends Menu

@onready var width_edit: SpinBox = %Width
@onready var height_edit: SpinBox = %Height


func _on_create_pressed() -> void:
	var x_value: int = roundi(width_edit.value)
	var y_value: int = roundi(height_edit.value)

	AppManager.create_file(Vector2i(x_value, y_value))

	close()


func _on_cancel_pressed() -> void:
	close()
