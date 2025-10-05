extends TextureRect

@onready var phoneButton := $roomButtons/phoneButton
@onready var callButton1 := $roomButtons/callButton1
@onready var callButton2 := $roomButtons/callButton2
@onready var callButton3 := $roomButtons/callButton3
@onready var callButton4 := $roomButtons/callButton4
@onready var callButton5 := $roomButtons/callButton5
@onready var callButton6 := $roomButtons/callButton6
@onready var callButton7 := $roomButtons/callButton7
@onready var callButton8 := $roomButtons/callButton8
@onready var callButton9 := $roomButtons/callButton9
@onready var endCallButton := $roomButtons/endCallButton
@onready var keysButton := $roomButtons/keysButton

var dialogue_counter = 0

func _ready() -> void:
	phoneButton.pressed.connect(handlePhoneCall.bind(0))
	callButton1.pressed.connect(handlePhoneCall.bind(1))
	callButton2.pressed.connect(handlePhoneCall.bind(2))
	callButton3.pressed.connect(handlePhoneCall.bind(3))
	callButton4.pressed.connect(handlePhoneCall.bind(4))
	callButton5.pressed.connect(handlePhoneCall.bind(5))
	callButton6.pressed.connect(handlePhoneCall.bind(6))
	callButton7.pressed.connect(handlePhoneCall.bind(7))
	callButton8.pressed.connect(handlePhoneCall.bind(8))
	callButton9.pressed.connect(handlePhoneCall.bind(9))
	endCallButton.pressed.connect(handlePhoneCall.bind(10))
	keysButton.pressed.connect(handlePhoneCall.bind(11))
	
func handlePhoneCall(call_line: int):
	phoneButton.visible = call_line + 1 == 0
	callButton1.visible = call_line + 1 == 1
	callButton2.visible = call_line + 1 == 2
	callButton3.visible = call_line + 1 == 3
	callButton4.visible = call_line + 1 == 4
	callButton5.visible = call_line + 1 == 5
	callButton6.visible = call_line + 1 == 6
	callButton7.visible = call_line + 1 == 7
	callButton8.visible = call_line + 1 == 8
	callButton9.visible = call_line + 1 == 9
	endCallButton.visible = call_line + 1 == 10
	keysButton.visible = call_line + 1 == 11
