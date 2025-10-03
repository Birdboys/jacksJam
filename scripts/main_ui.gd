extends Control

@onready var flashlightButton := $uiMargin/uiCont/botHbox/lightPanel/buttonMargin/flashlightButton
@onready var mouseLabel := $mouseLabel
@onready var roomButtons := $uiMargin/uiCont/topHbox/roomPanel/roomMargin/roomTexture/roomButtons

func _ready() -> void:
	flashlightButton.toggled.connect(toggleFlashlight)
	getRoomButtons()
	
func _process(delta: float) -> void:
	mouseLabel.global_position = get_global_mouse_position() + Vector2(16, 16)
	
func toggleFlashlight(on: bool):
	if on: return
	else: return

func getRoomButtons():
	for child in roomButtons.get_children():
		if child is RoomButton:
			print("found_button ", child.name)
			child.mouse_entered.connect(updateMouseText.bind(child.hover_text))
			child.mouse_exited.connect(clearMouseText)
			child.pressed.connect(roomButtonPressed.bind(child.button_id))
	
func updateMouseText(t):
	print("MOUSE ENTERED BUTTON ", t)
	mouseLabel.text = t
	
func clearMouseText():
	mouseLabel.text = ""

func roomButtonPressed(button_id: String):
	match button_id:
		"bed": print("do spooky thing")
		"clock": print("does spookier thing")
		"window_button_1": print("YOU CLICKED THE WINDOWW")
		_: pass
