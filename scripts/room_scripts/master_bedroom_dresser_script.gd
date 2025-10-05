extends TextureRect

@onready var keyButton := $roomButtons/keyButton

func _ready() -> void:
	keyButton.visible = not TriggerHandler.took_bedroom_key
	if TriggerHandler.took_bedroom_key:
		texture = load("res://assets/temp/room_views/dresser_no_key.png")

func tookKey():
	keyButton.visible = false
	texture = load("res://assets/temp/room_views/dresser_no_key.png")
