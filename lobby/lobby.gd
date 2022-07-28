extends Control

onready var player_name = $CenterContainer/VBoxContainer/GridContainer/NameTextBox
onready var selected_IP = $CenterContainer/VBoxContainer/GridContainer/IPTextBox
onready var selected_port = $CenterContainer/VBoxContainer/GridContainer/PortTextBox


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_JoinButton_pressed():
	# TODO do something with the name
	Server.local_player_name = player_name.text
	Server.ip = selected_IP.text
	Server.port = int(selected_port.text)
	Server.ConnectToServer() # Replace with function body.
	#Swap to world once is connected
	$WaitingRoom.show()
