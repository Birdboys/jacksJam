extends TextureRect

@onready var spookyGuy := $spookyGuy

var done_spook

func _ready() -> void:
	spookyGuy.mouse_entered.connect(tryDoScare)
	spookyGuy.visible = TriggerHandler.is_dark
	
func tryDoScare():
	if not (TriggerHandler.is_dark and TriggerHandler.flashlight_on): return
	if TriggerHandler.done_kids_bedroom_scare: return
	doScare()

func doScare():
	TriggerHandler.done_kids_bedroom_scare = true
	var scare_tween = get_tree().create_tween()
	scare_tween.tween_property(spookyGuy, "position", Vector2(936.0, 8.0), 0.6)
	scare_tween.tween_callback(spookyGuy.queue_free)
