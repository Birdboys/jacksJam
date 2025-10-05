extends Control

@onready var roomMargin := $uiMargin/uiCont/topHbox/roomPanel/roomMargin
@onready var roomTransitionAnim := $uiMargin/uiCont/topHbox/roomPanel/roomTransitionAnim

@onready var descriptionText := $uiMargin/uiCont/botHbox/textPanel/textMargin/descriptionText
@onready var flashlightButton := $uiMargin/uiCont/botHbox/lightPanel/buttonMargin/flashlightButton
@onready var mouseLabel := $mouseLabel
@onready var mouseItem := $mouseItem

@onready var taskMargin := $uiMargin/uiCont/topHbox/taskInventoryPanel/taskMargin
@onready var taskVbox := $uiMargin/uiCont/topHbox/taskInventoryPanel/taskMargin/taskVbox
@onready var inventoryMargin := $uiMargin/uiCont/topHbox/taskInventoryPanel/inventoryMargin
@onready var inventoryGrid := $uiMargin/uiCont/topHbox/taskInventoryPanel/inventoryMargin/inventoryGrid
@onready var panelTabs := $uiMargin/uiCont/topHbox/taskInventoryPanel/togglePanelButtons/panelTabs

var tasks := {}
var inventory_items := {}
var flashlight_on := false
var can_click := true
var current_room_resource : RoomResource
var current_item := ""
var roomButtons

func _ready() -> void:
	flashlightButton.toggled.connect(toggleFlashlight)
	panelTabs.tab_changed.connect(toggleTaskInventoryPanels)
	roomMargin.gui_input.connect(checkClearHeldItem)
	loadRoom("intro_phone")
	toggleTaskInventoryPanels(0)
	addTask("answer_phone", "Answer the phone")
	#addInventoryItem("key", load("res://assets/temp/key.jpeg"))
	
func _process(delta: float) -> void:
	mouseLabel.global_position = get_global_mouse_position() + Vector2(16, 16)
	mouseItem.global_position = get_global_mouse_position() + Vector2(-36, -36)
	RenderingServer.global_shader_parameter_set("mouse_pos", get_global_mouse_position())

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		clearHeldItem()
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		clearHeldItem()
		
func toggleFlashlight(on: bool):
	flashlight_on = on
	if on: 
		handleFlashlightEvent(current_room_resource.room_flashlight_on_event)
	else: 
		handleFlashlightEvent(current_room_resource.room_flashlight_off_event)
	RenderingServer.global_shader_parameter_set("flashlight_on", flashlight_on)
	
func loadRoom(room_name, do_transition=true):
	can_click = false
	clearMouseText()
	clearHeldItem()
	
	if do_transition:
		roomTransitionAnim.play("transition_room_begin")
		await roomTransitionAnim.animation_finished
	
	unloadCurrentRoom()
	var new_room_resource = load("res://scripts/room_resources/%s.tres" % room_name) as RoomResource
	var new_room_scene = new_room_resource.room_scene.instantiate()
	roomMargin.add_child(new_room_scene)
	roomButtons = new_room_scene.find_child("roomButtons")
	getRoomButtons()
	
	var backButton = new_room_scene.find_child("backButton")
	if backButton: backButton.pressed.connect(handleBackButtonPressed.bind(new_room_resource.back_room_id))
	
	current_room_resource = new_room_resource
	
	if do_transition:
		roomTransitionAnim.play("transition_room_end")
		await roomTransitionAnim.animation_finished
	
	var new_room_text = new_room_resource.room_text
	
	can_click = true
	loadText(new_room_text)
	handleRoomEnterEvent(new_room_resource.room_enter_event)
	
func unloadCurrentRoom():
	clearRoomButtons()
	if roomMargin.get_child(0): roomMargin.get_child(0).queue_free()
	descriptionText.text = ""
	
func getRoomButtons():
	for child in roomButtons.get_children():
		if child is RoomButton:
			print("found_button ", child.name)
			child.mouse_entered.connect(updateMouseText.bind(child.hover_text))
			child.mouse_exited.connect(clearMouseText)
			child.pressed.connect(roomButtonPressed.bind(child.button_id))

func clearRoomButtons():
	if roomButtons:
		for child in roomButtons.get_children():
			if child is RoomButton:
				child.mouse_entered.disconnect(updateMouseText)
				child.mouse_exited.disconnect(clearMouseText)
				child.pressed.disconnect(roomButtonPressed)

func updateRoomButtons():
	clearRoomButtons()
	getRoomButtons()
	
func clearText():
	descriptionText.text = ""
	
func loadText(t):
	for x in range(len(t)):
		if not can_click: return
		descriptionText.text += t[x]
		await get_tree().create_timer(0.02).timeout
	
func updateMouseText(t):
	if not can_click: return
	mouseLabel.text = t
	
func clearMouseText():
	mouseLabel.text = ""

func roomButtonPressed(button_event: String):
	if not can_click: return
	match button_event:
		"front_door_button": 
			loadRoom("entrance")
			completeTask("enter_house")
			removeInventoryItem("key")
			addInventoryItem("lighter", load("res://assets/temp/lighter.jpg"))
			addInventoryItem("grabber", load("res://assets/temp/grabber.jpg"))
			#toggleDark(true)
			
		#INTRO BUTTONS
		"answer_phone":
			completeTask("answer_phone")
			clearText()
			clearMouseText()
			loadText("Phony tony's, you got ghosts we got solutions, how can I help you?")
		"call_line_1":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[1])
		"call_line_2":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[2])
		"call_line_3":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[3])
		"call_line_4":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[4])
		"call_line_5":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[5])
		"call_line_6":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[6])
		"call_line_7":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[7])
		"call_line_8":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[8])
		"call_line_9":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[9])
		"end_call":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[10])
			addTask("grab_keys", "Take keys")
		"take_keys":
			loadRoom("front_door_test")
			addInventoryItem("truck_keys", load("res://assets/temp/truck_keys.jpg"))
			
		#ENTRANCE BUTTONS
		"go_up_stairs":
			loadRoom("upstairs")
		"go_dining_room":
			loadRoom("dining_room")
		"go_living_room":
			loadRoom("living_room")
		"go_kitchen":
			loadRoom("kitchen_test")
		
		#UPSTAIRS BUTTONS
		"go_down_stairs":
			loadRoom("entrance")
		"go_bathroom":
			loadRoom("bathroom")
		"go_master_bedroom":
			loadRoom("master_bedroom")
		"go_kids_bedroom":
			toggleDark(true)
			loadRoom("kids_bedroom")
			
		#DINING ROOM BUTTONS
		"look_table":
			pass
		
		#LIVING ROOM BUTTONS
		"look_window":
			loadRoom("living_room_window")
			
		#MASTER BEDROOM BUTTONS
		"look_dresser":
			loadRoom("master_bedroom_dresser")
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

func handleBackButtonPressed(room_id):
	toggleDark(false)
	loadRoom(room_id)
	
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

func removeTask(task_id):
	if task_id not in tasks: return
	tasks[task_id].queue_free()
	tasks.erase(task_id)
	
func clearTasks():
	for t in tasks:
		tasks[t].queue_free()

func addInventoryItem(item_id, item_image):
	var new_inventory_item = load("res://scenes/inventory_item.tscn").instantiate() as InventoryItem
	inventoryGrid.add_child(new_inventory_item)
	new_inventory_item.texture = item_image
	new_inventory_item.item_id = item_id
	new_inventory_item.use_item.connect(useInventoryItem)
	inventory_items[item_id] = new_inventory_item

func removeInventoryItem(item_id):
	if item_id not in inventory_items: return
	inventory_items[item_id].queue_free()
	inventory_items.erase(item_id)

func clearInventoryItems():
	for i in inventory_items:
		inventory_items[i].queue_free()
	inventory_items = {}

func useInventoryItem(item_id):
	if item_id not in inventory_items: return
	mouseItem.texture = inventory_items[item_id].texture
	current_item = item_id

func checkClearHeldItem(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		clearHeldItem()
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		clearHeldItem()
	
func clearHeldItem():
	print("CLEARING ITEM")
	mouseItem.texture = null
	current_item = ""

func toggleDark(on: bool):
	RenderingServer.global_shader_parameter_set("is_dark", on)
