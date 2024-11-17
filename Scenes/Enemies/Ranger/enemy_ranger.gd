extends CharacterBody2D

enum MOVEMODE {
	CHASING,
	FLEEING,
	AIMING,
	WAITING,
}

@export_group("Health and Damage")
## Maximum total health base
@export var base_max_hp: float = 24
## HP increase per level
@export var max_hp_scaling: float = 12
## Attack damage per hit
@export var damage: float = 16

@export_group("Shoot Settings")
## Aiming build up time before shooting
@export var aim_duration: float = 2
## Cooldown after shooting in seconds
@export var shoot_cooldown: float = 1.5
@export var max_range: float = 800

@export_group("Movement")
## How fast this enemy normally moves
@export var move_speed: float = 75
@export var min_flee_range: float = 300
@export var max_flee_range: float = 600
## How far an object can be before the enemy detects it in pixels
@export var collision_detection_range: float = 150
## 
@export var seek_weight: float = 1
##
@export var avoid_weight: float = 100

var state = MOVEMODE.AIMING
var player
var distance_to_player
var aim_build_up = 0

var current_speed = 0.0

# Aim
var predicted_position

# Debug Draw
var raycast_from = Vector2.ZERO
var raycast_to = Vector2.ZERO
var predict_from = Vector2.ZERO
var predict_to = Vector2.ZERO

# Directions for object detection
var ray_directions = []

var seek_map = []
var collision_map = []
var seek_map_buffer = 0.5

func _ready():
	player = Player.current
	$Timer.timeout.connect(_on_Timer_timeout)
	
	# Generate ray directions
	var num_directions = 16
	var angle_increment = 360.0 / num_directions
	
	for x in range(num_directions):
		var angle_rad = deg_to_rad(x * angle_increment)
		ray_directions.append(Vector2(cos(angle_rad), sin(angle_rad)).normalized())

func update_distance_to_player():
	distance_to_player = (player.global_position - global_position).length()

func _physics_process(delta: float) -> void:
	update_distance_to_player()
	if (distance_to_player <= min_flee_range):
		state = MOVEMODE.FLEEING
	# State Machine
	match state:
		MOVEMODE.CHASING:
			handle_chasing_state(delta)
		MOVEMODE.FLEEING:
			handle_fleeing_state(delta)
		MOVEMODE.AIMING:
			handle_aiming_state(delta)
		MOVEMODE.WAITING:
			handle_waiting_state()

func handle_chasing_state(delta: float) -> void:
	var steering_force = get_steering(false)
	
	if take_aim():
		state = MOVEMODE.AIMING
		return
	
	velocity += steering_force * delta
	
	if velocity.length() > move_speed:
		velocity = velocity.normalized() * move_speed
	move_and_slide()

func handle_fleeing_state(delta: float) -> void:
	var steering_force = get_steering(true)
	
	if distance_to_player >= max_flee_range and take_aim():
		state = MOVEMODE.AIMING
		return
	
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
		query.collision_mask = 1
		
		# Perform the raycast
		var result = space_state.intersect_ray(query)
		if result:
			collision_map[x] = global_position.distance_to(result.position)

func update_seek_map(player_position: Vector2, fleeing: bool) -> void:
	seek_map.clear()
	var to_player = (player_position - global_position)
	if fleeing:
		to_player *= -1
	
	# Loop over each direction and calculate projection
	for dir in ray_directions:
		var projection = to_player.normalized().dot(dir)
		seek_map.append(max(0, projection) + seek_map_buffer)

# Return the final movement velocity vector based on Seek and Avoid vectors
func get_steering(fleeing: bool) -> Vector2:
	var final_vector = Vector2.ZERO
	
	update_collision_map()
	update_seek_map(player.global_position, fleeing)
	
	for x in range(seek_map.size()):
		var final_move_desire = seek_map[x] - (collision_map[x] * avoid_weight)
		seek_map[x] = (max(0, final_move_desire))
		
		final_vector += ray_directions[x] * seek_map[x]
	
	if final_vector.length() > 0:
		final_vector = final_vector.normalized() * move_speed
	
	return final_vector

# Aim at the player for the aim_duration, if still in range, dash
func handle_aiming_state(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if !take_aim(): 
		state = MOVEMODE.CHASING # SET TO CHASING
		aim_build_up = 0
		return

	aim_build_up += delta
	if aim_build_up >= aim_duration:
		shoot()
		aim_build_up = 0

# Aim at the player, return true if player is in range and unobstructed
func take_aim() -> bool:
	# Null catch for debugging, should be ok to remove with draw method
	raycast_from = global_position
	raycast_to = global_position
	# =====================================================
	
	if distance_to_player >= max_range:
		return false
	
	raycast_from = global_position
	raycast_to = raycast_from + (player.global_position - raycast_from).normalized() \
		* max_range
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = raycast_from
	query.to = raycast_to
	query.collision_mask = (1 << 0) | (1 << 4)
	
	var result = space_state.intersect_ray(query)
	if result.get("collider") != player:
		return false
	
	# Debug drawing
	call_deferred("queue_redraw")
	
	return true

func shoot() -> void:
	print(shoot)

func handle_waiting_state() -> void:
	pass

func _on_Timer_timeout():
	state = MOVEMODE.AIMING

func die() -> void:
	set_process(false)
	# Trigger death animation
	# $AnimationPlayer.play("death")
	# Play sound effect
	# $AudioStreamPlayer.play()
	# Emit a death signal, useful for later
	# emit_signal("enemy_died")
	# await $AnimationPlayer.animation_finished
	queue_free()

# Debugging
func _draw() -> void:
	var local_from = to_local(raycast_from)
	var local_to = to_local(raycast_to)

	draw_line(local_from, local_to, Color.RED, 2)
