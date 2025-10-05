extends TextureRect

@onready var shelfButton := $roomButtons/shelfButton
@onready var journalButton := $roomButtons/journalButton

func _ready() -> void:
	journalButton.visible = TriggerHandler.has_grabby_arm
