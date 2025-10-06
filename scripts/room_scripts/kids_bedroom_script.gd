extends TextureRect

@onready var spookyGuy := $spookyGuy
@onready var grabberButton := $roomButtons/grabberButton
var done_spook

func _ready() -> void:
	grabberButton.visible = not TriggerHandler.took_grabby_arm
	if TriggerHandler.took_grabby_arm: texture = load("res://assets/temp/room_views/kids_bedroom_no_grabber.png")
	
	spookyGuy.mouse_entered.connect(tryDoScare)
	spookyGuy.visible = TriggerHandler.is_dark

func tookGrabber():
	grabberButton.visible = false
	texture = load("res://assets/temp/room_views/kids_bedroom_no_grabber.png")
	
func tryDoScare():
	if not (TriggerHandler.is_dark and TriggerHandler.flashlight_on): return
	if TriggerHandler.done_kids_bedroom_scare: return
	doScare()

func doScare():
	TriggerHandler.done_kids_bedroom_scare = true
	var scare_tween = get_tree().create_tween()
	scare_tween.tween_property(spookyGuy, "position", Vector2(936.0, 8.0), 0.6)
	scare_tween.tween_callback(spookyGuy.queue_free)
