extends Control

@onready var roomMargin := $uiMargin/uiCont/topHbox/roomPanel/roomMargin

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
var current_room_resource : RoomResource
var current_item := ""
var roomButtons

func _ready() -> void:
	flashlightButton.toggled.connect(toggleFlashlight)
	panelTabs.tab_changed.connect(toggleTaskInventoryPanels)
	roomMargin.gui_input.connect(checkClearHeldItem)
	loadRoom("front_door_test")
	addTask("enter_house", "Enter house")
	toggleTaskInventoryPanels(0)
	addInventoryItem("key", load("res://assets/temp/key.jpeg"))
	
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
	clearHeldItem()
	
func getRoomButtons():
	for child in roomButtons.get_children():
		if child is RoomButton:
			print("found_button ", child.name)
			child.mouse_entered.connect(updateMouseText.bind(child.hover_text))
			child.mouse_exited.connect(clearMouseText)
			child.pressed.connect(roomButtonPressed.bind(child.button_id))
func clearText():
	descriptionText.text = ""
	
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
		"pillow":
			toggleDark(false)
			loadRoom("kitchen_test")
		"front_door_button": 
			loadRoom("hospital_test")
			completeTask("enter_house")
			removeInventoryItem("key")
			addInventoryItem("lighter", load("res://assets/temp/lighter.jpg"))
			addInventoryItem("grabber", load("res://assets/temp/grabber.jpg"))
			toggleDark(true)
		"hospital_door": 
			toggleDark(false)
			loadRoom("front_door_test")
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
	RenderingServer.global_shader_parameter_set("do_flashlight", on)
