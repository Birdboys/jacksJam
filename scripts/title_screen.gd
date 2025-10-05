extends Control

var playing = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and not playing:
		playing = true
		get_tree().change_scene_to_file("res://scenes/main_ui.tscn")
