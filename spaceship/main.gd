extends Node

@export var rock_scene : PackedScene
var screensize = Vector2.ZERO
var level = 0
var score = 0
var playing = false

func _ready():
	screensize = get_viewport().get_visible_rect().size
	

func new_game():
	get_tree().call_group("rocks","queue_free")
	level = 0
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Player.reset()
	await $HUD/Timer.timeout
	playing = true

func new_level():
	level += 1
	$HUD.show_message("Wave %s" % level) #same as "Wave " + str(level)
	for i in level:
		spawn_rock(3)

func spawn_rock(size, pos=null, vel=null):
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	var r = rock_scene.instantiate()
	r.screensize = screensize
	r.start(pos, vel, size)
	call_deferred("add_child", r)
	r.exploded.connect(self._on_rock_exploded)

func _on_rock_exploded(size, radius, pos, vel):
	if size <= 1:
		return
	for offset in [-1,1]:
		var direction = $Player.position.direction_to(pos).orthogonal() * offset
		var newpos = pos + direction * radius
		var newvel = direction * vel.length() * 1.1
		spawn_rock(size-1, newpos, newvel)

func _process(_delta):
	if not playing:
		return
	if get_tree().get_nodes_in_group("rocks").size() == 0:
		new_level()

func game_over():
	playing = false
	$HUD.game_over()




#placeholder so code is more towards the middle of the screen


func update_lives() -> void:
	pass # Replace with function body.
