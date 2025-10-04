extends Control

@onready var roomMargin := $uiMargin/uiCont/topHbox/roomPanel/roomMargin

@onready var descriptionText := $uiMargin/uiCont/botHbox/textPanel/textMargin/descriptionText
@onready var flashlightButton := $uiMargin/uiCont/botHbox/lightPanel/buttonMargin/flashlightButton
@onready var mouseLabel := $mouseLabel

@onready var taskMargin := $uiMargin/uiCont/topHbox/taskInventoryPanel/taskMargin
@onready var taskVbox := $uiMargin/uiCont/topHbox/taskInventoryPanel/taskMargin/taskVbox
@onready var inventoryMargin := $uiMargin/uiCont/topHbox/taskInventoryPanel/inventoryMargin
@onready var panelTabs := $uiMargin/uiCont/topHbox/taskInventoryPanel/togglePanelButtons/panelTabs

var tasks := {}
var flashlight_on := false
var current_room_resource : RoomResource
var roomButtons

func _ready() -> void:
	flashlightButton.toggled.connect(toggleFlashlight)
	panelTabs.tab_changed.connect(toggleTaskInventoryPanels)
	loadRoom("front_door_test")
	addTask("enter_house", "Enter house")
	toggleTaskInventoryPanels(0)
	
func _process(delta: float) -> void:
	mouseLabel.global_position = get_global_mouse_position() + Vector2(16, 16)
	RenderingServer.global_shader_parameter_set("mouse_pos", get_global_mouse_position())

func toggleFlashlight(on: bool):
	flashlight_on = on
	if on: 
		handleFlashlightEvent(current_room_resource.room_flashlight_on_event)
	else: 
		handleFlashlightEvent(current_room_resource.room_flashlight_off_event)

func loadRoom(room_name):
	unloadCurrentRoom()
	var new_room_resource = load("res://scripts/room_resources/%s.tres" % room_name) as RoomResource
	var new_room_scene = new_room_resource.room_scene.instantiate()
	roomMargin.add_child(new_room_scene)
	roomButtons = new_room_scene.find_child("roomButtons")
	getRoomButtons()
	
	var new_room_text = new_room_resource.room_text
	loadText(new_room_text)
	
	handleRoomEnterEvent(new_room_resource.room_enter_event)
	
	current_room_resource = new_room_resource
	
func unloadCurrentRoom():
	if roomButtons:
		for child in roomButtons.get_children():
			if child is RoomButton:
				child.mouse_entered.disconnect(updateMouseText)
				child.mouse_exited.disconnect(clearMouseText)
				child.pressed.disconnect(roomButtonPressed)
	roomMargin.get_child(0).queue_free()
	descriptionText.text = ""
	clearMouseText()
	
func getRoomButtons():
	for child in roomButtons.get_children():
		if child is RoomButton:
			print("found_button ", child.name)
			child.mouse_entered.connect(updateMouseText.bind(child.hover_text))
			child.mouse_exited.connect(clearMouseText)
			child.pressed.connect(roomButtonPressed.bind(child.button_id))

func loadText(t):
	for x in range(len(t)):
		descriptionText.text += t[x]
		await get_tree().create_timer(0.05).timeout
	
func updateMouseText(t):
	mouseLabel.text = t
	
func clearMouseText():
	mouseLabel.text = ""

func roomButtonPressed(button_event: String):
	match button_event:
		"bed": print("do spooky thing")
		"clock": print("does spookier thing")
		"front_door_button": 
			loadRoom("hospital_test")
			completeTask("enter_house")
		"hospital_door": loadRoom("front_door_test")
		_: pass
		
func handleFlashlightEvent(event_id):
	match event_id:
		"spooky_hospital": loadRoom("hospital_dark_test")
		"normal_hospital": loadRoom("hospital_test")
		"hallway_1_light": loadRoom("hallway_1_dark")
		"hallway_1_dark": loadRoom("hallway_2_light")
		
func handleRoomEnterEvent(event_id):
	match event_id:
		"play_spooky_footstep": 
			AudioHandler.playSound("footsteps", Vector3.LEFT)

func toggleTaskInventoryPanels(tab_id):
	print("TAB: ", tab_id)
	if tab_id == 0:
		taskMargin.visible = true
		inventoryMargin.visible = false
	else:
		taskMargin.visible = false
		inventoryMargin.visible = true
		
func addTask(task_id, task_text):
	var new_task_label = Label.new()
	taskVbox.add_child(new_task_label)
	new_task_label.theme_type_variation = "taskUnfinished"
	new_task_label.text = task_text
	tasks[task_id] = new_task_label

func completeTask(task_id):
	tasks[task_id].theme_type_variation = "taskFinished"
	
func clearTasks():
	for t in tasks:
		tasks[t].queue_free()
