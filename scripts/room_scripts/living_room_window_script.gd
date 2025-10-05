extends TextureRect

@onready var saltButton := $roomButtons/saltButton
@onready var windowButton := $roomButtons/windowButton

func _ready() -> void:
	if TriggerHandler.salted_window:
		saltButton.visible = false
		windowButton.visible = true
		texture = load("res://assets/temp/room_views/living_room_window_salted.png")
	else:
		saltButton.visible = true
		windowButton.visible = false
		
func saltPlaced():
	saltButton.visible = false
	windowButton.visible = true
	texture = load("res://assets/temp/room_views/living_room_window_salted.png")
