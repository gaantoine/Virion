extends CharacterBody2D

var pop_distance = 300
var number_to_spawn = 3
var spawn_delay = 0.1 # set to a really small number to make instant, increase to add delay between spawns

var player: Player:
	get: return Player.current

var distance_to_player = 0
var spawn_counter = 0
var spawning_active = false  # Flag to control spawning
const SWARM_SCENE = preload("res://Scenes/Enemies/Swarm/EnemySwarm.tscn")

func update_distance_to_player():
	distance_to_player = (player.global_position - global_position).length()

func _physics_process(delta: float) -> void:
	update_distance_to_player()
	if not spawning_active:
		$AnimationTree.set("parameters/Pod_Idle/active", true)
		$AnimationTree.set("parameters/Pod_Burst/active", false)
	
	
	# Check if spawning should begin
	if not spawning_active and distance_to_player <= pop_distance:
		$AnimationTree.set("parameters/Pod_Idle/active", false)
		$AnimationTree.set("parameters/Pod_Burst/active", true)
		spawning_active = true
		spawn_next()

func spawn_next():
	if spawn_counter < number_to_spawn:
		var new_instance = SWARM_SCENE.instantiate()
		get_tree().root.add_child(new_instance)
		new_instance.global_position = global_position
		spawn_counter += 1
		$Timer.start(spawn_delay)  # Continue spawning after a delay
	else:
		finish_spawning()

func _on_timer_timeout() -> void:
	spawn_next()  # Spawn the next instance when the timer times out

func finish_spawning():
	spawn_counter = 0  # Reset counter for future spawns
	spawning_active = false  # Allow spawning to trigger again
	queue_free()  # Optional: remove the spawner node if it's temporary
