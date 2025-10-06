extends TextureRect

@onready var placeBoxButton := $roomButtons/placeBoxButton
@onready var spiritBoxButton := $roomButtons/spiritBoxButton
@onready var tableButton := $roomButtons/tableButton

func _ready() -> void:
	if TriggerHandler.spirit_boxed_dining_room:
		spiritBoxButton.visible = true
		placeBoxButton.visible = false
		texture = load("res://assets/temp/room_views/dining_room_spirit_box.png")
	elif TriggerHandler.has_spirit_box:
		spiritBoxButton.visible = false
		placeBoxButton.visible = true
		print("BOX BUTTONS HOULD BE VISIBLE")
	else:
		spiritBoxButton.visible = false
		placeBoxButton.visible = false
		
func placedSpiritBox():
	texture = load("res://assets/temp/room_views/dining_room_spirit_box.png")
	spiritBoxButton.visible = true
	placeBoxButton.visible = false
