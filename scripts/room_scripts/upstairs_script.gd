extends TextureRect

@onready var spookyGuy := $spookyGuy

func _ready() -> void:
	spookyGuy.mouse_entered.connect(tryDoScare)
	spookyGuy.visible = TriggerHandler.is_dark and not TriggerHandler.done_hallway_scare

func tryDoScare():
	if not (TriggerHandler.is_dark and TriggerHandler.flashlight_on): return
	if TriggerHandler.done_hallway_scare: return
	doScare()

func doScare():
	TriggerHandler.done_hallway_scare = true
	var scare_tween = get_tree().create_tween().set_parallel(true)
	scare_tween.tween_property(spookyGuy, "position", Vector2(1002.0, 176.0), 0.75)
	scare_tween.tween_property(spookyGuy, "scale", Vector2(2,2), 0.75)
	await scare_tween.finished
	spookyGuy.queue_free()
