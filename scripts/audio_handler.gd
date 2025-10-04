extends Camera3D

@onready var players := $playerQueue
var num_players := 5
var player_queue : Array[AudioStreamPlayer3D] = []
#var player_queue : Array[AudioStreamPlayer] = []
var player_queue_id := 0
var player_position_offset := 25

func _ready() -> void:
	#make_current()
	populatePlayers()
	
func populatePlayers():
	for x in range(num_players):
		var new_player = AudioStreamPlayer3D.new()
		#var new_player = AudioStreamPlayer.new()
		players.add_child(new_player)
		player_queue.append(new_player)
	print(players.get_children())
	
func playSound(sound_name, sound_dir := Vector3.ZERO, sound_dist = player_position_offset):
	if not FileAccess.file_exists("res://assets/sounds/%s.wav" % sound_name):
		print("Sound not found: %s" % sound_name)
		return
	player_queue[player_queue_id].stream = load("res://assets/sounds/%s.wav" % sound_name)
	player_queue[player_queue_id].position = sound_dir * sound_dist
	player_queue[player_queue_id].play()
	player_queue_id = wrapi(player_queue_id+1, 0, num_players)
	
