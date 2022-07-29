extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 60090

# Clock sync 
var latency = 0
var client_clock = 0
var delta_latency = 0
var decimal_collector : float = 0
var latency_array = []

# Lobby data
var local_player_id
var local_player_name
sync var players = {}
sync var player_data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)

	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to connect")

func _OnConnectionSucceeded():
	# Clock Sync
	print("Succesfully connected")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)
	
	# Register Player for lobby 
	register_player()
	rpc_id(1, "send_player_info", local_player_id, player_data)
	
# Lobby and Waiting Room related functions
func register_player():
	local_player_id = get_tree().get_network_unique_id()
	player_data["name"] = local_player_name
	players[local_player_id] = player_data
	
sync func update_waiting_room():
	get_tree().call_group("WaitingRoom", "refresh_players", players)
	
func load_game():
	rpc_id(1, "load_world")
	
remote func start_game():
	get_node("../SceneHandler").start_game()

# General sync functions

func fetchSomeData(requestedData, requester):
	rpc_id(1, "getData", requestedData, requester)
	
remote func returnData(s_data, requester):
	instance_from_id(requester).setDataComingFromServer(s_data)

remote func SpawnPlayer(player_id, spawn_postion):
	get_node("../SceneHandler/Main/World").SpawnPlayer(player_id, spawn_postion)
	
remote func DispawnPlayer(player_id):
	get_node("../SceneHandler/Main/World").DispawnPlayer(player_id)

func sendPlayerState(player_state):
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)

remote func ReceiveWorldState(world_state):
	get_node("../SceneHandler/Main/World").UpdateWorldState(world_state)

remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
	print(server_time, " ", client_time)
	
func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())
	
remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20 and latency_array[i] < 0:
				latency_array.remove(i)
			else: 
				total_latency += latency_array[i]
		
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		latency_array.clear()

func SendAttack(position, direction):
	rpc_id(1, "Attack", position, direction, client_clock)
	
remote func ReceiveAttack(position, direction, spawn_time, player_id):
	if player_id == get_tree().get_network_unique_id():
		pass
	else:
		get_node("/root/SceneHandler/Main/World/OtherPlayers/" + str(player_id)).attack_dict[spawn_time] = {"Position": position, "Direction": direction}
		
remote func ReceiveDamage(damage, damage_time, player_id):
	if player_id == get_tree().get_network_unique_id():
		get_node("/root/SceneHandler/Main/Player").damage_dict[damage_time] = {"Health": damage}
	else:
		str(player_id)
		print(get_node("/root/SceneHandler/Main/World/OtherPlayers/" + str(player_id)))
		get_node("/root/SceneHandler/Main/World/OtherPlayers/" + str(player_id)).damage_dict[damage_time] = {"Health": damage}
