extends TextureRect

@onready var dresserButton := $roomButtons/dresserButton
@onready var bedButton := $roomButtons/bedButton
@onready var underBedButton := $roomButtons/underBedButton
@onready var tableButton := $roomButtons/tableButton

func _ready() -> void:
	underBedButton.visible = TriggerHandler.under_bed_found
	
func foundUnderBed():
	underBedButton.visible = true
