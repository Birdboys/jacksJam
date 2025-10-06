extends TextureRect

var safe_code := "5223"
var current_guess := ""

@onready var safe_buttons := {
	1: $safeUI/one,
	2: $safeUI/two,
	3: $safeUI/three,
	4: $safeUI/four,
	5: $safeUI/five,
	6: $safeUI/six,
	7: $safeUI/seven,
	8: $safeUI/eight,
	9: $safeUI/nine
}

signal safe_opened
signal safe_failed

func _ready() -> void:
	for b in safe_buttons:
		safe_buttons[b].pressed.connect(tryUnlockSafe.bind(b))
		
func tryUnlockSafe(button_id):
	if TriggerHandler.safe_opened: return
	AudioHandler.playSound("safe_beep")
	current_guess += str(button_id)
	if len(current_guess) == 4:
		if current_guess == safe_code:
			emit_signal("safe_opened")
		else:
			emit_signal("safe_failed")
		current_guess = ""
