extends Node

var mapstart = preload("res://Main.tscn")
var lobby = preload("res://lobby/lobby.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var lobby_instance = lobby.instance()
	add_child(lobby_instance)
	#var mapstart_instance = mapstart.instance()
	#add_child(mapstart_instance)

func start_game():
	var mapstart_instance = mapstart.instance()
	add_child(mapstart_instance)
	var node = get_node("Lobby")
	get_node("Lobby").queue_free()
