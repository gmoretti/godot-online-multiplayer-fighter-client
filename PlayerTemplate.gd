extends KinematicBody2D

var bullet = preload("res://Weapons/Projectiles/GunBullet.tscn")
var attack_dict = {}
var damage_dict = {}

var max_hp
var current_hp
var display_name

func MovePlayer(new_position, animation_vector):
	set_position(new_position)
	$Sprite.scale.x = animation_vector.y

func _physics_process(_delta):
	if not attack_dict == {}:
		Attack()
	if not damage_dict == {}:
		ReceiveDamage()
		
func Attack():
	for attack in attack_dict.keys():
		if attack <= Server.client_clock:
			var bullet_instance = bullet.instance()
			#set_position(attack_dict[attack]["Position"] - Vector2(50 * bullet_instance.direction.y, -15))
			bullet_instance.position = attack_dict[attack]["Position"]
			bullet_instance.direction = attack_dict[attack]["Direction"]
			#bullet_instance.original = false
			attack_dict.erase(attack)
			get_parent().add_child(bullet_instance)
			
func ReceiveDamage():
	for damage in damage_dict.keys():
		if damage <= Server.client_clock:
			current_hp = damage_dict[damage]["Health"]
			$Health.text = str(current_hp) + "%"
			damage_dict.erase(damage)

func set_display_name(display_name_from_server):
	display_name = display_name_from_server
	$DisplayName.text = display_name
