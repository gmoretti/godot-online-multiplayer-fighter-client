extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 60
const MAXFALLSPEED = 300
const MAXSPEED = 400
const JUMPFORCE = 1000
const ACCEL = 80

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var motion = Vector2()
var animation_vector = Vector2()
var facing_right = true
var serverData;
var player_state

var max_hp
var current_hp
var damage_dict = {}
var display_name

# Weapons
var bullet = preload("res://Weapons/Projectiles/GunBullet.tscn")
var can_fire = true
var rate_of_fire = 0.4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	SkillLoop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	movementLoop(delta)
	definePlayerState()
	if not damage_dict == {}:
		ReceiveDamage()
	
func SkillLoop():
	if Input.is_action_pressed("shoot") and can_fire == true:
		can_fire = false
		var bullet_instance = bullet.instance()
		bullet_instance.position = get_global_position() + Vector2(50 * animation_vector.normalized().y, -15)
		#bullet_instance.rotation = get_angle_to(get_global_mouse_position())
		bullet_instance.direction = Vector2(animation_vector.normalized().y, 0)
		Server.SendAttack(bullet_instance.position, bullet_instance.direction)
		
		get_parent().add_child(bullet_instance)
		yield(get_tree().create_timer(rate_of_fire), "timeout")
		can_fire = true
	
func definePlayerState():
	player_state = {
		"T":Server.client_clock,
		"P":get_global_position(),
		"A": animation_vector
	}
	Server.sendPlayerState(player_state)

func movementLoop(_delta):
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	if facing_right == true:
		$Sprite.scale.x = 1.5
		animation_vector = Vector2(0,1.5)
	else:
		$Sprite.scale.x = -1.5
		animation_vector = Vector2(0,-1.5)
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	if Input.is_action_pressed("right"):
		motion.x += ACCEL
		facing_right = true
	elif Input.is_action_pressed("left"):
		motion.x += -ACCEL
		facing_right = false
	else:
		motion.x = lerp(motion.x,0,0.2)
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			motion.y = -JUMPFORCE	
			# Server.fetchSomeData("data", get_instance_id())
	
	motion = move_and_slide(motion, UP)
	
func setDataComingFromServer(s_data):
	serverData = s_data
	print("Data loaded from server: " + serverData)

func ReceiveDamage():
	for damage in damage_dict.keys():
		if damage <= Server.client_clock:
			current_hp = damage_dict[damage]["Health"]
			$Health.text = str(current_hp) + "%"
			damage_dict.erase(damage)

func set_display_name(display_name_from_server):
	display_name = display_name_from_server
	$DisplayName.text = display_name
