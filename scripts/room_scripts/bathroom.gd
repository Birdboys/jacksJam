extends TextureRect

@onready var shelfButton := $roomButtons/shelfButton
@onready var journalButton := $roomButtons/journalButton

func _ready() -> void:
	journalButton.visible = TriggerHandler.knocked_journal_down
	if TriggerHandler.knocked_journal_down:
		texture = load("res://assets/temp/room_views/bathroom_book_fallen.png")

func journalFell():
	journalButton.visible = true
	texture = load("res://assets/temp/room_views/bathroom_book_fallen.png")
