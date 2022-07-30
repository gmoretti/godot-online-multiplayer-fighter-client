extends RigidBody2D

var projectile_speed = 1500
var direction = Vector2()
var life_time = 3
var original = true

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_impulse(Vector2(), direction * projectile_speed)
	$Bullet.scale.x = direction.x
	$sound.play()
	#apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))
	SelfDistruct()
	
func SelfDistruct():
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()

func _on_Bullet_body_entered(_body):
	get_node("CollisionShape2D").set_deferred("disabled", true)
	self.hide()
