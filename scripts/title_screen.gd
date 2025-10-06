extends Control

var playing = false

func _on_start_button_pressed() -> void:
	playing = true
	get_tree().change_scene_to_file("res://scenes/main_ui.tscn")
