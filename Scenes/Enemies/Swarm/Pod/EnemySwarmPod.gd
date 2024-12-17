extends CharacterBody2D
@onready var animation_tree : AnimationTree = $Pod_AnimationTree

#Gonna need this for spawners
@export var SpawnRef: Node2D

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

func _physics_process(_delta: float) -> void:
	update_distance_to_player()
	
	# Check if spawning should begin
	if not spawning_active and distance_to_player <= pop_distance:
		spawning_active = true
		animation_tree["parameters/conditions/Burst"] = true
		spawn_next()

func spawn_next():
	if spawn_counter < number_to_spawn:
		var new_instance = SWARM_SCENE.instantiate()
		get_tree().root.add_child(new_instance)
		new_instance.global_position = global_position
		new_instance.SpawnRef = self.SpawnRef
		spawn_counter += 1
		SpawnRef.IncSpawn()
		$Timer.start(spawn_delay)  # Continue spawning after a delay
	else:
		finish_spawning()

func _on_timer_timeout() -> void:
	spawn_next()  # Spawn the next instance when the timer times out

func finish_spawning():
	SpawnRef.EnemyDie()
	
	spawn_counter = 0  # Reset counter for future spawns
	spawning_active = false  # Allow spawning to trigger again
	queue_free()  
