extends Node2D

const interpolation_offset = 100

var last_world_sate = 0
var player_spawn = preload("res://PlayerTemplate.tscn")
var player_local = preload("res://Player.tscn")
var world_state_buffer = []

func SpawnPlayer(player_id, spawn_position):
	if (get_tree().get_network_unique_id() == player_id):
		if not get_node("/root/SceneHandler/Main").has_node("Player"):
			var new_player = player_local.instance()
			new_player.position = spawn_position
			new_player.name = "Player"
			get_node("/root/SceneHandler/Main").add_child(new_player)
	else:
		if not get_node("OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			get_node("./OtherPlayers").add_child(new_player)

func DispawnPlayer(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("./OtherPlayers/" + str(player_id)).queue_free()
	
func UpdateWorldState(world_state):
	if world_state["T"] > last_world_sate:
		last_world_sate = world_state["T"]
		world_state_buffer.append(world_state)

func _physics_process(_delta):
	var render_time = Server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"])/float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					
					var animation_vector = world_state_buffer[2][player]["A"]
					get_node("OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
				else:
					print("Spawning player")
					SpawnPlayer(player, world_state_buffer[2][player]["P"])

		elif render_time > world_state_buffer[1]["T"]:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("OtherPlayers/").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					
					var animation_vector = world_state_buffer[1][player]["A"]
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					get_node("OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
