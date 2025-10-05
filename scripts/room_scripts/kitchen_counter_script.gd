extends TextureRect

@onready var paperButton := $roomButtons/paperButton
@onready var coinButton := $roomButtons/coinButton
@onready var keyButton := $roomButtons/keyButton

func _ready() -> void:
	keyButton.visible = not TriggerHandler.took_kitchen_key
	coinButton.visible = not TriggerHandler.took_kitchen_coins
	
	if TriggerHandler.took_kitchen_coins and TriggerHandler.took_kitchen_key:
		texture = load("res://assets/temp/room_views/kitchen_counter_nothing.png")
	elif TriggerHandler.took_kitchen_coins:
		texture = load("res://assets/temp/room_views/kitchen_counter_no_coins.png")
	elif TriggerHandler.took_kitchen_key:
		texture = load("res://assets/temp/room_views/kitchen_counter_no_key.png")

func tookKey():
	keyButton.visible = false
	if TriggerHandler.took_kitchen_coins:
		texture = load("res://assets/temp/room_views/kitchen_counter_nothing.png")
	else:
		texture = load("res://assets/temp/room_views/kitchen_counter_no_key.png")

func tookCoins():
	coinButton.visible = false
	if TriggerHandler.took_kitchen_key:
		texture = load("res://assets/temp/room_views/kitchen_counter_nothing.png")
	else:
		texture = load("res://assets/temp/room_views/kitchen_counter_no_coins.png")
