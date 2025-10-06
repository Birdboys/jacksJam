extends Control

var playing = false

func _on_start_button_pressed() -> void:
	playing = true
	get_tree().change_scene_to_file("res://scenes/room_scenes/intro_phone.tscn")
