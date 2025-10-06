extends Control

@onready var roomMargin := $uiMargin/uiCont/topHbox/roomPanel/roomMargin
@onready var roomTransitionAnim := $uiMargin/uiCont/topHbox/roomPanel/roomTransitionAnim
@onready var bottomUIAnim := $uiMargin/uiCont/botHbox/bottomUIAnim

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
var can_click := false
var current_room_resource : RoomResource
var current_room_scene 
var current_item := ""
var roomButtons

func _ready() -> void:
	flashlightButton.toggled.connect(toggleFlashlight)
	panelTabs.tab_changed.connect(toggleTaskInventoryPanels)
	roomMargin.gui_input.connect(checkClearHeldItem)
	#loadRoom("entrance")
	#loadRoom("front_door_test")
	#await startSpooky()
	loadRoom("intro_phone")
	toggleTaskInventoryPanels(0)
	addTask("answer_phone", "Answer the phone")
	#startSpooky()
	#addInventoryItem("key", load("res://assets/temp/key.jpeg"))
	
func _process(delta: float) -> void:
	mouseLabel.visible = can_click
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
	TriggerHandler.flashlight_on = on
	if on: 
		handleFlashlightEvent(current_room_resource.room_flashlight_on_event)
	else: 
		handleFlashlightEvent(current_room_resource.room_flashlight_off_event)
	AudioHandler.playSound("flashlight_click")
	RenderingServer.global_shader_parameter_set("flashlight_on", flashlight_on)
	
func loadRoom(room_name, do_transition=true):
	can_click = false
	clearMouseText()
	clearHeldItem()
	
	if do_transition:
		roomTransitionAnim.play("transition_room_begin")
		await roomTransitionAnim.animation_finished
		AudioHandler.playSound("transition_footsteps")
	unloadCurrentRoom()
	var new_room_resource = load("res://scripts/room_resources/%s.tres" % room_name) as RoomResource
	var new_room_scene = new_room_resource.room_scene.instantiate()
	roomMargin.add_child(new_room_scene)
	roomButtons = new_room_scene.find_child("roomButtons")
	getRoomButtons()
	
	var backButton = new_room_scene.find_child("backButton")
	if backButton: backButton.pressed.connect(handleBackButtonPressed.bind(new_room_resource.back_room_id))
	
	current_room_resource = new_room_resource
	current_room_scene = new_room_scene
	
	if current_room_scene.has_signal("safe_opened"):
		current_room_scene.safe_opened.connect(safeOpened)
		current_room_scene.safe_failed.connect(safeFailed)
		
	if do_transition:
		roomTransitionAnim.play("transition_room_end")
		await roomTransitionAnim.animation_finished
	
	var new_room_text = new_room_resource.room_text
	
	handleRoomEnterEvent(new_room_resource.room_enter_event)
	loadText(new_room_text)
	
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
	can_click = false
	descriptionText.visible_characters = 0.0
	descriptionText.text = t
	for x in range(len(t)):
		#if not can_click: return
		descriptionText.visible_characters += 1
		if t[x] in [","," ",".","?","!"]: await get_tree().create_timer(0.04).timeout
		else: 
			AudioHandler.playSound("typewriter")
			await get_tree().create_timer(0.02).timeout
		
	descriptionText.visible_characters =  -1.0
	can_click = true
	
func updateMouseText(t):
	#if not can_click: return
	mouseLabel.text = t
	
func clearMouseText():
	mouseLabel.text = ""

func roomButtonPressed(button_event: String):
	if not can_click: return
	can_click = false
	match button_event:
			
		#INTRO BUTTONS
		"answer_phone":
			completeTask("answer_phone")
			clearText()
			clearMouseText()
			AudioHandler.playSound("pickup_phone")
			AudioHandler.stopLoopingSound("phone_ring")
			loadText("Phony tony's, you got ghosts we got solutions, how can I help you?")
			current_room_scene.handlePhoneCall(0)
		"call_line_1":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[1])
			current_room_scene.handlePhoneCall(1)
		"call_line_2":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[2])
			current_room_scene.handlePhoneCall(2)
		"call_line_3":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[3])
			current_room_scene.handlePhoneCall(3)
		"call_line_4":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[4])
			current_room_scene.handlePhoneCall(4)
		"call_line_5":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[5])
			current_room_scene.handlePhoneCall(5)
		"call_line_6":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[6])
			current_room_scene.handlePhoneCall(6)
		"call_line_7":
			clearText()
			loadText(DialogueHandler.phone_call_dialogue[7])
			current_room_scene.handlePhoneCall(7)
		#"call_line_8":
			#clearText()
			#loadText(DialogueHandler.phone_call_dialogue[8])
			#current_room_scene.handlePhoneCall(8)
		#"call_line_9":
			#clearText()
			#loadText(DialogueHandler.phone_call_dialogue[9])
			#current_room_scene.handlePhoneCall(9)
		"end_call":
			clearText()
			AudioHandler.playSound("put_down_phone")
			loadText(DialogueHandler.phone_call_dialogue[8])
			addTask("grab_keys", "Take keys")
			current_room_scene.handlePhoneCall(8)
		"take_keys":
			current_room_scene.handlePhoneCall(9)
			current_room_scene.keysTaken()
			addInventoryItem("truck_keys", load("res://assets/inventory_icons/keys.png"))
			completeTask("grab_keys")
			AudioHandler.playSound("van_start")
			await loadText("Lets go...")
			await get_tree().create_timer(0.5).timeout
			loadRoom("front_door_test")
			addTask("enter_house", "Enter house")
		
		#FRONT DOOR BUTTONS
		"knock_button_1":
			AudioHandler.playSound("door_knocking")
			loadText(DialogueHandler.front_door_dialogue[0])
			current_room_scene.handleDialogue(1)
		"knock_button_2":
			AudioHandler.playSound("door_knocking")
			loadText(DialogueHandler.front_door_dialogue[1])
			current_room_scene.handleDialogue(2)
		"knock_button_3":
			AudioHandler.playSound("door_knocking")
			loadText(DialogueHandler.front_door_dialogue[2])
			current_room_scene.handleDialogue(3)
		"front_door_button":
			AudioHandler.playSound("open_door")
			current_room_scene.handleDialogue(4)
			await loadText(DialogueHandler.front_door_dialogue[3])
			await get_tree().create_timer(1.0).timeout
			loadRoom("entrance")
			completeTask("enter_house")
			#clearTasks()
			removeInventoryItem("key")
			clearTasks()
			addTask("salt_window", "Salt living \nroom window")
			addInventoryItem("salt", load("res://assets/inventory_icons/salt.png"))
		
		#ENTRANCE BUTTONS
		"go_up_stairs":
			loadRoom("upstairs")
		"go_dining_room":
			loadRoom("dining_room")
		"go_living_room":
			loadRoom("living_room")
		"go_kitchen":
			loadRoom("kitchen")
		
		#FRONT DOOR INSIDE BUTTONS:
		"leave_house":
			if current_item == "lighter":
				await loadText("IM FREE")
				await get_tree().create_timer(2.0).timeout
				get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
			elif TriggerHandler.is_spooky:
				loadText("Damnit! It's locked, I'm trapped. Gotta find another way to get through.")
			else:
				loadText("Nah, can't leave yet. I'm a scammer but Georgie deserves more than this.")

				
		#KITCHEN BUTTONS:
		"kitchen_fridge":
			loadText("It smells rank over here, not opening that fella.")
		"kitchen_table":
			loadRoom("kitchen_counter")
		"kitchen_microwave":
			loadText("It definitely isn't 3:00 AM... Welp, I didn't break it.")
		"kitchen_sink":
			loadText("They clearly need a dish washing schedule.")
		"kitchen_cabinet":
			if TriggerHandler.took_lighter:
				loadText("Nothing else to find in this guy.")
			elif TriggerHandler.took_counter_key:
				loadText("Wowwy I found a lighter")
				addInventoryItem("lighter", load("res://assets/inventory_icons/lighter.png"))
				TriggerHandler.took_lighter = true
			else:
				loadText("The cabinets are locked. Shame, I bet there's some good stuff inside.")
		
		#KITCHEN COUNTER BUTTONS:
		"look_newspaper":
			loadText("That's a lot of words. Too bad I'm not reading em'.")
		"take_kitchen_coins":
			TriggerHandler.took_kitchen_coins = true
			AudioHandler.playSound("coin_pickup")
			loadText("My favorite part of the job is collecting coins… actually, I think it's spendin em’.") 
			current_room_scene.tookCoins()
			addInventoryItem("kitchen_coins", load("res://assets/inventory_icons/coins.png"))
			
		#UPSTAIRS BUTTONS
		"go_down_stairs":
			loadRoom("entrance")
		"go_bathroom":
			loadRoom("bathroom")
		"go_master_bedroom":
			loadRoom("master_bedroom")
		"go_kids_bedroom":
			if TriggerHandler.opened_kids_door:
				AudioHandler.playSound("open_door")
				loadRoom("kids_bedroom")
			elif current_item == "bedroom_key":
				TriggerHandler.opened_kids_door = true
				AudioHandler.playSound("open_door")
				loadRoom("kids_bedroom")
			else:
				loadText("Hm... the door is locked.")
			
		#DINING ROOM BUTTONS
		"look_dining_table":
			loadText("What a lovely dining table")
		"use_spirit_box":
			if current_item == "spirit_box":
				loadText("It's part of my procedure to use this static machine to \"detect\" ghosts. Normally I have to ask to be alone. Emf time now.")
				AudioHandler.playSound("static")
				TriggerHandler.spirit_boxed_dining_room = true
				TriggerHandler.has_emf = true
				#removeInventoryItem("spirit_box")
				addInventoryItem("emf", load("res://assets/inventory_icons/emf.png"))
				completeTask("spirit_box")
				addTask("emf", "Use emf in\nmaster bedroom")
				current_room_scene.placedSpiritBox()
				
				#TESTY FOR NOW
				#startSpooky()
			else:
				loadText("I need to use the spirit box")
				
		"look_spirit_box":
			loadText("What a lovely box")
		
		#LIVING ROOM BUTTONS
		"look_window":
			loadRoom("living_room_window")
		"look_couch":
			loadText("I love old comfy lookin couches.")
		"look_living_table":
			loadText("Nice table, might put my feet up for a bit when I’m done.")
		"look_tv":
			loadText("A nice piece, if it weren't so heavy I'd nab it.")
			
		#LIVING ROOM WINDOW BUTTONS
		"look_at_window":
			loadText("Nice and salty")
			
		"salt_window":
			if current_item == "salt":
				loadText("Usually I don't do this, but it'll prove I was actually here. Not going to do an unpaid job.")
				AudioHandler.playSound("salt_shake")
				TriggerHandler.salted_window = true
				TriggerHandler.has_spirit_box = true
				current_room_scene.saltPlaced()
				clearHeldItem()
				completeTask("salt_window")
				addTask("spirit_box", "Use spirit box\nin dining room")
				addInventoryItem("spirit_box", load("res://assets/inventory_icons/spirit_box.png"))
			else:
				loadText("I need salt to put on the window")
				
		#MASTER BEDROOM BUTTONS
		"look_dresser":
			loadRoom("master_bedroom_dresser")
		"look_master_bed":
			if TriggerHandler.has_emf and current_item == "emf":
				loadText("The metal detector is triggering... something must be under the bed.")
				TriggerHandler.under_bed_found = true
				current_room_scene.foundUnderBed()
				AudioHandler.playSound("metal_detector")
				completeTask("emf")
				addTask("under_bed", "Check under\nthe bed")
			else:
				loadText("It's a nice bed.")
		"look_master_table":
			if TriggerHandler.has_emf and current_item == "emf":
				loadText("Nothing spooky here, other than this ugly lamp.")
				#AudioHandler.playSound("metal_detected")
			else:
				loadText("What an ugly lamp.")
		"look_under_bed":
			completeTask("under_bed")
			loadText("Goin under...")
			loadRoom("under_bed")
			#loadRoom("under_bed")
		
		#UNDER BED BUTTONS
		"open_safe": 
			if TriggerHandler.took_counter_key:
				loadText("Shame there was only a key, but I'm sure it'll come in handy somewhere.")
			else:
				loadText("Ooooh, a safe! There's gotta be something nice in here.")
		
		#MASTER BEDROOM DRESSER BUTTONS
		"look_dresser_phone":
			loadText("The lines not workin. Damn.")
		"look_dresser_picture":
			loadText("Good old Georgie. Wonder where he's at.")
		"take_dresser_key":
			TriggerHandler.took_bedroom_key = true
			addInventoryItem("bedroom_key", load("res://assets/inventory_icons/old_key.png"))
			loadText("Yoink.")
			current_room_scene.tookKey()
		
		#KIDS BEDROOM BUTTONS
		"take_grabber":
			TriggerHandler.took_grabby_arm = true
			addInventoryItem("grabber", load("res://assets/inventory_icons/grabber.png"))
			loadText("Nothing is out of reach for Tony Gabaghoul!")
			current_room_scene.tookGrabber()
		"look_teddybear":
			loadText("Aw a little teddy weddy bear. Always tell the stupid family theres something spooky about their stuffed animals.")
		"look_toys":
			loadText("A buncha blocks and shapes. I could even count em if I wanted.")
		"look_kids_lamp":
			loadText("Now that's a nice lamp. Got a good glow to it.")
		"look_kids_bed":
			loadText("I never got to meet Georgie's kid.")
		
		#BATHROOM BUTTONS
		"look_bathtub":
			loadText("What kinda lunatic leaves their tub filled? And with black water no less.")
		"look_sink":
			loadText("I know there's not gonna be anything behind me, but mirrors still give me the willies.")
		"look_toilet":
			loadText("Gah! Who didn't flush! Animals... animals I tell ya.")
		"look_shelf":
			if TriggerHandler.knocked_journal_down:
				loadText("Nothing up there anymore, it's just a shelf.")
			elif current_item == "grabber":
				if not TriggerHandler.knocked_journal_down:
					current_room_scene.journalFell()
					TriggerHandler.knocked_journal_down = true
					loadText("Success! Its... a journal. I guess I can read what's inside.")
				else:
					loadText("Nothing up there anymore, it's just a shelf.")
			else:
				loadText("I think there's something up there, but I can't reach it.")
		"look_journal":
			loadText("It reads: \"First cubes, then rings, then cones, then spheres.\" What the heck Georgie?")
		_: pass
	clearHeldItem()
		
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
		"phone_ring":
			AudioHandler.playLoopingSound("phone_ring")
			
func handleBackButtonPressed(room_id):
	if not can_click: return
	if room_id == "master_bedroom" and not TriggerHandler.is_spooky and current_room_resource.room_flashlight_on_event == "under_bed":
		await startSpooky()
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
	#toggleTaskInventoryPanels(0)

func completeTask(task_id):
	if task_id not in tasks: return
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
	TriggerHandler.is_dark = on
	RenderingServer.global_shader_parameter_set("is_dark", on)

func startSpooky():
	clearTasks()
	addTask("leave", "Leave the house")
	TriggerHandler.is_spooky = true
	AudioHandler.playSound("lights_out")
	toggleDark(true)
	await loadText("Huh... the lights went out. Thank god for my flashlight. Let's leave.")
	bottomUIAnim.play("load_flashlight")
	AudioHandler.startSpookyShit()

func safeOpened():
	if not can_click: return
	if TriggerHandler.took_counter_key:
		loadText("Nothing else in this bad boy.")
		return
	AudioHandler.playSound("open_door")
	loadText("Haha! Yes! Open sesame. Oooh, there's a key inside.")
	TriggerHandler.took_counter_key = true
	addInventoryItem("counter_key", load("res://assets/inventory_icons/old_key.png"))
	
func safeFailed():
	if not can_click: return
	loadText("Damn, thats not the right combo...")
