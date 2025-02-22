extends RigidBody2D

enum {INIT, ALIVE, INVULNERABLE, DEAD}
#Array is States of Being for the Player and is numbered 0,1,2,3

var state = INIT
#when we load the player we want to be in the alive state.
#we can use the _ready function for this

#character movement/ force values
@export var engine_power = 500
@export var spin_power = 8000
var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize = Vector2.ZERO
@export var bullet_scene : PackedScene
@export var fire_rate = 0.25
#if you can shoot
var can_shoot = true
signal lives_changed
signal dead
var reset_positon = false
var lives = 0: set = set_lives


func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate

func change_state(new_state):
	#match - switch/case aka an if statement with a set of known values that match
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled",true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled",false)
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled",true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled",true)
	state = new_state

func _process(_delta):
	get_input()

func get_input():
	thrust = Vector2.ZERO
	#check state to see if dead or init. use array to check for multiple
	if state in [DEAD, INIT]:
		return #returns values into other variable or exit function
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left","rotate_right")
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

#we are going to introduce a new process function called physics process
#any time we deal with movement or physics based calculations we use it here.

func _physics_process(_delta):
	constant_force = thrust
	constant_torque = rotation_dir*spin_power

#timestamp 01:21:15 on part 1

#we need to change position/transform our player. We dont often
#directly access the physics system but when we do we use integrate forces

func _integrate_forces(physics_state):
	#grab current transform/position from physics_process
	var xform = physics_state.transform
	#origin is an object (a way to wrap properties together) that contains
	#position, scale, rotation, and skew
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	#apply the wrap to the other side ^
	physics_state.transform = xform
	if reset_positon: 
		physics_state.transform.origin = screensize / 2
		reset_positon = false

#shoot function
func shoot():
	if state == INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)

func _on_gun_cooldown_timeout():
	can_shoot = true

func set_lives(value):
	lives = value
	lives_changed.emit(lives)
	if lives <= 0:
		change_state(DEAD)
	else:
		change_state(INVULNERABLE)

func reset():
	reset_positon = true
	$Sprite2D.show()
	lives = 3
	change_state(ALIVE)



#place holder so I can keep the code in the middle of my screen
