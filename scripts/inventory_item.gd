extends TextureRect
class_name InventoryItem

var item_id : String

signal use_item(id: String)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("use_item", item_id)
