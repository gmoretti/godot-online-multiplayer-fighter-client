extends Popup

onready var player_list = $CenterContainer/VBoxContainer/ItemList
onready var ready_btn = $CenterContainer/VBoxContainer/ReadyButton

func _ready():
	player_list.clear()
	
func refresh_players(players):
	player_list.clear()
	for player_id in players:
		var playerName = players[player_id]["name"]
		player_list.add_item(playerName, null, false)


func _on_ReadyButton_pressed():
	Server.load_game()
	ready_btn.disabled = true
