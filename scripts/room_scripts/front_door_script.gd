extends TextureRect

@onready var knockButton1 := $roomButtons/knockButton1
@onready var knockButton2 := $roomButtons/knockButton2
@onready var knockButton3 := $roomButtons/knockButton3
@onready var enterButton := $roomButtons/enterButton

func _ready() -> void:
	knockButton1.pressed.connect(handleDialogue.bind(1))
	knockButton2.pressed.connect(handleDialogue.bind(2))
	knockButton3.pressed.connect(handleDialogue.bind(3))
	enterButton.pressed.connect(handleDialogue.bind(4))
	
func handleDialogue(id):
	knockButton1.visible = id + 1 == 1
	knockButton2.visible = id + 1 == 2
	knockButton3.visible = id + 1 == 3
	enterButton.visible = id + 1 == 4
