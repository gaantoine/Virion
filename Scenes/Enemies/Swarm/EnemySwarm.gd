extends CharacterBody2D

enum MOVEMODE {
	CHASING,
	WAITING,
}

@onready var SwarmDamageAudio = $Swarm_Damage
@onready var SwarmDeathAudio = $Swarm_Death
@onready var SwarmFootstepAudio = $Swarm_Footstep
@onready var SwarmAttackAudio = $Swarm_Attack

@export_group("Health and Damage")
## Maximum total health base
@export var base_max_hp: float = 24
#
var current_hp = base_max_hp
## HP increase per level (ex. level 3 HP = 24 + (12 + 12))
@export var max_hp_scaling: float = 12
## Attack damage per hit
@export var damage: float = 16
@export var attack_radius: float = 50

@export_group("Movement")
## How fast this enemy normally moves
@export var move_speed: float = 200
@export var min_flee_range: float = 300
@export var max_flee_range: float = 400
## How far an object can be before the enemy detects it in pixels
@export var collision_detection_range: float = 150
## 
@export var seek_weight: float = 1
##
@export var avoid_weight: float = 100
@export var aggro_range: float = 900

@onready var animation_tree : AnimationTree = $Swarm_AnimationTree

var state = MOVEMODE.CHASING
var player:Player:
	get:return Player.current
var distance_to_player

var current_speed = 0.0

# Directions for object detection
var ray_directions = []

var seek_map = []
var collision_map = []
var seek_map_buffer = 0.5

var last_facing_direction
var dead = false


func _ready():
	animation_tree.active = true
	$Timer.timeout.connect(_on_Timer_timeout)
	
	# Generate ray directions
	var num_directions = 16
	var angle_increment = 360.0 / num_directions
	
	for x in range(num_directions):
		var angle_rad = deg_to_rad(x * angle_increment)
		ray_directions.append(Vector2(cos(angle_rad), sin(angle_rad)).normalized())


func update_distance_to_player():
	distance_to_player = (player.global_position - global_position).length()


func on_spawn(level_counter: float) -> void:
	current_hp = base_max_hp + (max_hp_scaling * (level_counter - 1))


func _physics_process(delta: float) -> void:
	update_distance_to_player()
	if (distance_to_player >= aggro_range):
		state = MOVEMODE.WAITING
	if (distance_to_player < attack_radius):
		player.take_damage(damage)
		animation_tree["parameters/conditions/attack"] = true
		animation_tree["parameters/conditions/walk"] = false
		animation_tree["parameters/conditions/death"] = false
	if (distance_to_player > attack_radius):
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/walk"] = true
		animation_tree["parameters/conditions/death"] = false
		
	# State Machine
	match state:
		MOVEMODE.CHASING:
			handle_chasing_state(delta)
		MOVEMODE.WAITING:
			handle_waiting_state()


func handle_chasing_state(delta: float) -> void:
	var steering_force = get_steering()
	
	if velocity:
		last_facing_direction = velocity.normalized()
	$Swarm_AnimationTree.set("parameters/Attack/blend_position", last_facing_direction)
	$Swarm_AnimationTree.set("parameters/Walk/blend_position", last_facing_direction)
	
	velocity += steering_force * delta
	
	if velocity.length() > move_speed:
		velocity = velocity.normalized() * move_speed
	move_and_slide()


func update_collision_map() -> void:
	collision_map.clear()
	var space_state = get_world_2d().direct_space_state
	
	for x in range(ray_directions.size()):
		collision_map.append(0)
		var query = PhysicsRayQueryParameters2D.new()
		query.from = global_position
		query.to = global_position + ray_directions[x] * collision_detection_range
		query.collision_mask = 1 | (1 << 2) | (1 << 4)
		
		# Perform the raycast
		var result = space_state.intersect_ray(query)
		if result:
			collision_map[x] = global_position.distance_to(result.position)


func update_seek_map(player_position: Vector2) -> void:
	seek_map.clear()
	var to_player = (player_position - global_position)

	# Loop over each direction and calculate projection
	for dir in ray_directions:
		var projection = to_player.normalized().dot(dir)
		seek_map.append(max(0, projection) + seek_map_buffer)


# Return the final movement velocity vector based on Seek and Avoid vectors
func get_steering() -> Vector2:
	var final_vector = Vector2.ZERO
	
	update_collision_map()
	update_seek_map(player.global_position)
	
	for x in range(seek_map.size()):
		var final_move_desire = seek_map[x] - (collision_map[x] * avoid_weight)
		seek_map[x] = (max(0, final_move_desire))
		
		final_vector += ray_directions[x] * seek_map[x]
	
	if final_vector.length() > 0:
		final_vector = final_vector.normalized() * move_speed
	
	return final_vector


func handle_waiting_state() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	if distance_to_player > aggro_range:
		state = MOVEMODE.CHASING
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/walk"] = true
		animation_tree["parameters/conditions/death"] = false


func _on_Timer_timeout():
	state = MOVEMODE.CHASING
	animation_tree["parameters/conditions/attack"] = false
	animation_tree["parameters/conditions/walk"] = true
	animation_tree["parameters/conditions/death"] = false


func take_damage(damage_taken: float) -> void:
	current_hp -= damage_taken
	# $AnimationPlayer.play("damage")
	# $Sprite.modulate = Color.RED # Maybe?
	# Play sound effect
	SwarmDamageAudio.play()
	if dead:
		return
	elif current_hp <= 0:
		dead = true
		die()
	else:
		$SwarmSpriteSheet.modulate = Color.RED
		await get_tree().create_timer(3/60.0).timeout
		$SwarmSpriteSheet.modulate = Color.WHITE


func take_knockback(displacement: Vector2) -> void:
	pass


func die() -> void:
	$Timer.stop()
	velocity = Vector2.ZERO
	set_physics_process(false)
	animation_tree["parameters/conditions/attack"] = false
	animation_tree["parameters/conditions/walk"] = false
	animation_tree["parameters/conditions/death"] = true
	# Play sound effect
	SwarmDeathAudio.play()
	# Emit a death signal, useful for later
	#emit_signal("enemy_died")
	await $Swarm_AnimationTree.animation_finished
	queue_free()
	
func call_swarm_attack() -> void:
	SwarmAttackAudio.play()
	
func call_swarm_footstep() -> void:
	SwarmFootstepAudio.play()
