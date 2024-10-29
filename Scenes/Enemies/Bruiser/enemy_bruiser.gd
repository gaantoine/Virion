extends CharacterBody2D

enum MOVEMODE {
	AIMING,
	DASHING,
	ATTACKING,
	DECELERATING,
	WAITING,
}

@export_group("Health and Damage")
## Maximum total health base
@export var base_max_hp: float = 24
## HP increase per level
@export var max_hp_scaling: float = 12
## Attack damage per hit
@export var damage: float = 16

@export_group("Dash Settings")
##
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
@export var middash_attack_range: float = 10
## Duration of the pause after attacks in seconds
@export var attack_duration: float = 1.0

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

var player
var state = MOVEMODE.WAITING
var distance_to_player

func _ready():
	player = Player.current
	$Timer.timeout.connect(_on_Timer_timeout)

func update_distance_to_player():
	distance_to_player = (player.global_position - global_position).length()

func _physics_process(delta: float) -> void:
	update_distance_to_player()
	match state:
		MOVEMODE.AIMING:
			handle_aiming_state(delta)
		MOVEMODE.DASHING:
			handle_dashing_state(delta)
		MOVEMODE.DECELERATING:
			handle_decelerating_state(delta)
		MOVEMODE.WAITING:
			handle_waiting_state()

# Aim at the player for the aim_duration, if still in range, dash
func handle_aiming_state(delta: float) -> void:
	if take_aim():
		charge_build_up += delta
		if charge_build_up >= aim_duration:
			start_dashing()
	else:
		charge_build_up = 0

# Dash for dash_duration
func handle_dashing_state(delta: float) -> void:
	dash_timer += delta
	
	if distance_to_player <= middash_attack_range:
		# Make this attack state later
		state = MOVEMODE.WAITING
		$Timer.start(post_dash_cooldown)
	
	var collision = move_and_collide(dash_direction * dash_speed * delta)
	if collision or dash_timer >= dash_duration:
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

func handle_waiting_state() -> void:
	if velocity != Vector2.ZERO:
		velocity = Vector2.ZERO
	move_and_slide()

# Aim at the player, return true if player is in range and unobstructed
func take_aim() -> bool:
	raycast_from = global_position
	var deceleration_distance = (dash_speed * dash_speed) / (2 * deceleration)
	
	raycast_to = raycast_from + (player.global_position - raycast_from).normalized() \
		* (dash_speed * dash_duration + deceleration_distance)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = raycast_from
	query.to = raycast_to
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	
	predicted_position = player.global_position + player.velocity * lead_time
	dash_direction = (predicted_position - global_position).normalized()
	
	predict_from = global_position
	predict_to = global_position + dash_direction * dash_speed 
	
	call_deferred("queue_redraw")
	
	if result and result.collider == player:
		return true
	return false

# Debugging
func _draw() -> void:
	var local_from = to_local(raycast_from)
	var local_to = to_local(raycast_to)

	draw_line(local_from, local_to, Color.RED, 2)
	
	local_from = to_local(predict_from)
	local_to = to_local(predict_to)
	
	draw_line(local_from, local_to, Color.GREEN, 2)

func start_dashing():
	charge_build_up = 0
	state = MOVEMODE.DASHING
	current_speed = dash_speed
	dash_timer = 0.0

func stop_dashing():
	state = MOVEMODE.DECELERATING
	$Timer.start(post_dash_cooldown)

func _on_Timer_timeout():
	state = MOVEMODE.AIMING
