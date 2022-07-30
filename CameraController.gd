extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	var x = get_parent().get_global_position().x
	var y = get_parent().get_global_position().y
	set_global_position(Vector2(x,y))
