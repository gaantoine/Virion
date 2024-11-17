extends CharacterBody2D

enum MOVEMODE {
	CHASING,
	AIMING,
	DASHING,
	ATTACKING,
	DECELERATING,
	WAITING,
}

@export_group("Health and Damage")
## Maximum total health base
@export var base_max_hp: float = 24
# current HP, can implement scaling per level progressed later if needed
var current_hp = base_max_hp
## HP increase per level, does nothing currently
@export var max_hp_scaling: float = 12
## Attack damage per hit
@export var damage: float = 16


@export_group("Dash Settings")
## Aiming build up time before dashing
@export var aim_duration: float = 0.75
## Speed of the dash
@export var dash_speed: float = 900
## Total duration of the dash in seconds
@export var dash_duration: float = 0.4
## Cooldown after a dash in seconds
@export var post_dash_cooldown: float = 1.5
## How far the dash will lead the player
@export var lead_time: float = 0.3
## Deceleration magnitutde
@export var deceleration: float = 3000
## The distance within which the player needs to be mid charge before the
## attack animation is triggered in pixels
@export var middash_attack_range: float = 100
## Duration of the pause after attacks in seconds
@export var attack_duration: float = 1.0

@export_group("Movement")
## How fast this enemy normally moves
@export var move_speed: float = 75
## How far an object can be before the enemy detects it in pixels
@export var collision_detection_range: float = 150
## 
@export var seek_weight: float = 1
##
@export var avoid_weight: float = 100

var state = MOVEMODE.WAITING
var player
var distance_to_player

var dash_direction = Vector2.ZERO
var dash_timer = 0.0
var current_speed = 0.0
var charge_build_up = 0

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
	match state:
		MOVEMODE.CHASING:
			handle_chasing_state(delta)
		MOVEMODE.AIMING:
			handle_aiming_state(delta)
		MOVEMODE.DASHING:
			handle_dashing_state(delta)
		MOVEMODE.DECELERATING:
			handle_decelerating_state(delta)
		MOVEMODE.ATTACKING:
			handle_attacking_state()
		MOVEMODE.WAITING:
			handle_waiting_state()

# Aim at the player for the aim_duration, if still in range, dash
func handle_aiming_state(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if !take_aim(): 
		state = MOVEMODE.CHASING # SET TO CHASING
		charge_build_up = 0
		return

	charge_build_up += delta
	if charge_build_up >= aim_duration:
		if distance_to_player > middash_attack_range:
			start_dashing()
		else:
			state = MOVEMODE.ATTACKING
		charge_build_up = 0

# Aim at the player, return true if player is in range and unobstructed
func take_aim() -> bool:
	# Null catch for debugging, should be ok to remove with draw method
	raycast_from = global_position
	raycast_to = global_position
	predict_from = global_position
	predict_to = global_position
	# =====================================================
	
	var dash_distance = dash_speed * dash_duration + ((dash_speed * dash_speed) \
		/ (2 * deceleration))
	
	if distance_to_player >= dash_distance:
		return false
	
	raycast_from = global_position
	raycast_to = raycast_from + (player.global_position - raycast_from).normalized() \
		* dash_distance
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = raycast_from
	query.to = raycast_to
	query.collision_mask = (1 << 0) | (1 << 4)
	
	var result = space_state.intersect_ray(query)
	if result.get("collider") != player:
		return false
	
	predicted_position = player.global_position + player.velocity * lead_time
	dash_direction = (predicted_position - global_position).normalized()
	
	# Debug drawing
	predict_from = global_position
	predict_to = global_position + dash_direction * dash_speed 
	#call_deferred("queue_redraw")
	
	return true

# Dash for dash_duration
func handle_dashing_state(delta: float) -> void:
	dash_timer += delta
	
	# Check if within attack range or dash duration has ended
	if distance_to_player <= middash_attack_range:
		state = MOVEMODE.ATTACKING
		$Timer.start(post_dash_cooldown)
		return
	
	elif dash_timer >= dash_duration or move_and_collide(dash_direction * dash_speed * delta):
		state = MOVEMODE.DECELERATING
		current_speed = dash_speed

# Decelerate
func handle_decelerating_state(delta: float) -> void:
	current_speed -= deceleration * delta
	if current_speed <= 0:
		state = MOVEMODE.WAITING
		$Timer.start(post_dash_cooldown)
	else:
		velocity = dash_direction * current_speed
		move_and_slide()

# Attack
func handle_attacking_state() -> void:
	$Sprite2D.modulate = Color.RED
	$Timer.start(attack_duration)
	state = MOVEMODE.WAITING

# Chase
func handle_chasing_state(delta: float) -> void:
	var steering_force = get_steering()
	
	if take_aim():
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

# Wait
func handle_waiting_state() -> void:
	velocity = Vector2.ZERO
	move_and_slide()

# Helper method for dashing
func start_dashing():
	charge_build_up = 0
	state = MOVEMODE.DASHING
	current_speed = dash_speed
	dash_timer = 0.0

func _on_Timer_timeout():
	$Sprite2D.modulate = Color.WHITE
	state = MOVEMODE.AIMING

func take_damage(damage_taken: float) -> void:
	current_hp -= damage_taken
	if current_hp <= 0:
		die()

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
	
	local_from = to_local(predict_from)
	local_to = to_local(predict_to)
	
	draw_line(local_from, local_to, Color.GREEN, 2)
