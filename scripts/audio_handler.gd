extends Camera3D

@onready var players := $playerQueue
@onready var phoneSound := $phoneSound
@onready var rainSound := $rainSound
@onready var spookyAmbiance := $spookyAmbience
@onready var spookyTimer := $spookyTimer
@onready var spooky_sound_cooldown_min := 10
@onready var spooky_sound_cooldown_max := 30
var num_players := 10
#var player_queue : Array[AudioStreamPlayer3D] = []
var player_queue : Array[AudioStreamPlayer] = []
var player_queue_id := 0
var player_position_offset := 25
var multi_sounds := {"transition_footsteps":4, "typewriter":5, "flashlight_click":3}
var spooky_sounds := ["spooky_footsteps", "ghostSound", "spooky_breath", "spooky_creak_1", "spooky_creak_2"]
var sound_dirs := [Vector3.ZERO, Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]

func _ready() -> void:
	#make_current()
	populatePlayers()
	spookyTimer.timeout.connect(playSpookySound)
	
func populatePlayers():
	for x in range(num_players):
		#var new_player = AudioStreamPlayer3D.new()
		var new_player = AudioStreamPlayer.new()
		players.add_child(new_player)
		player_queue.append(new_player)
	print(players.get_children())
	
func playSound(sound_name, sound_dir := Vector3.ZERO, sound_dist = player_position_offset):
	var stream
	if sound_name in multi_sounds:
		sound_name = sound_name + "_" + str(randi_range(1, multi_sounds[sound_name]))
	if FileAccess.file_exists("res://assets/sounds/%s.wav" % sound_name):
		stream = load("res://assets/sounds/%s.wav" % sound_name)
	elif FileAccess.file_exists("res://assets/sounds/%s.mp3" % sound_name):
		stream = load("res://assets/sounds/%s.mp3" % sound_name)
	else: 
		return
	player_queue[player_queue_id].stream = stream
	#player_queue[player_queue_id].position = sound_dir * sound_dist
	player_queue[player_queue_id].play()
	player_queue_id = wrapi(player_queue_id+1, 0, num_players)
	
func playLoopingSound(sound_name):
	match sound_name:
		"phone_ring": phoneSound.play()
		
func stopLoopingSound(sound_name):
	match sound_name:
		"phone_ring": phoneSound.stop()

func startSpookyShit():
	spookyAmbiance.play()
	playSpookySound()
	
func playSpookySound():
	var stream = spooky_sounds.pick_random()
	var dir = sound_dirs.pick_random()
	playSound(stream, dir)
	spookyTimer.start(randi_range(spooky_sound_cooldown_min, spooky_sound_cooldown_max))
