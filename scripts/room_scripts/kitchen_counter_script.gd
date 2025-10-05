extends TextureRect

@onready var paperButton := $roomButtons/paperButton
@onready var coinButton := $roomButtons/coinButton

func _ready() -> void:
	coinButton.visible = not TriggerHandler.took_kitchen_coins
	
	if TriggerHandler.took_kitchen_coins:
		texture = load("res://assets/temp/room_views/kitchen_counter_nothing.png")

func tookCoins():
	coinButton.visible = false
	texture = load("res://assets/temp/room_views/kitchen_counter_nothing.png")
