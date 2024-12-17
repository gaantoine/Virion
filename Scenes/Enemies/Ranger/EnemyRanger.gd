extends CharacterBody2D

enum MOVEMODE {
	CHASING,
	FLEEING,
	AIMING,
	WAITING,
}

#Gonna need this for spawners
@export var SpawnRef: Node2D

@onready var RangerDamageAudio = $Ranger_Damage
@onready var RangerDeathAudio = $Ranger_Death
@onready var RangerMoveAudio = $Ranger_Move
@onready var RangerShootAudio = $Ranger_Shoot

@export_group("Health and Damage")
## Maximum total health base
@export var base_max_hp: float = 24
#
var current_hp = base_max_hp
## HP increase per level (ex. level 3 HP = 24 + (12 + 12))
@export var max_hp_scaling: float = 12
## Attack damage per hit
@export var damage: float = 16

@export_group("Shoot Settings")
## Aiming build up time before shooting
@export var aim_duration: float = 1.5
## Cooldown after shooting in seconds
@export var shoot_cooldown: float = 1.5
@export var lead_time: float = 0.3
@export var max_range: float = 800

@export_group("Movement")
## How fast this enemy normally moves
@export var move_speed: float = 75
@export var min_flee_range: float = 300
@export var max_flee_range: float = 400
## How far an object can be before the enemy detects it in pixels
@export var collision_detection_range: float = 150
## 
@export var seek_weight: float = 1
##
@export var avoid_weight: float = 100
@export var aggro_range: float = 900

@onready var animation_tree : AnimationTree = $Ranger_AnimationTree

#signal variable for ranger shooting to be used by listeners
signal ranger_shoot

var state = MOVEMODE.AIMING
var player:Player:
	get:return Player.current
var distance_to_player
var aim_build_up = 0

var current_speed = 0.0

# Aim
var predicted_position
const bullet := preload("res://Animations/VFX/projectile_2.tscn")

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
	if (distance_to_player <= min_flee_range):
		state = MOVEMODE.FLEEING
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/move"] = true
		animation_tree["parameters/conditions/death"] = false
	if (distance_to_player >= aggro_range):
		state = MOVEMODE.WAITING
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/move"] = false
		animation_tree["parameters/conditions/death"] = false
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
			
	if(velocity != Vector2.ZERO):
		animation_tree["parameters/Idle/blend_position"] = velocity.normalized()
		animation_tree["parameters/Move/blend_position"] = velocity.normalized()

func handle_chasing_state(delta: float) -> void:
	var steering_force = get_steering(false)
	
	if take_aim():
		state = MOVEMODE.AIMING
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/move"] = false
		animation_tree["parameters/conditions/death"] = false
		return
	
	velocity += steering_force * delta
	
	if velocity.length() > move_speed:
		velocity = velocity.normalized() * move_speed
	move_and_slide()

func handle_fleeing_state(delta: float) -> void:
	var steering_force = get_steering(true)
	
	if distance_to_player >= max_flee_range and take_aim():
		state = MOVEMODE.AIMING
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/move"] = false
		animation_tree["parameters/conditions/death"] = false
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
	animation_tree["parameters/conditions/attack"] = false
	animation_tree["parameters/conditions/idle"] = true
	animation_tree["parameters/conditions/move"] = false
	animation_tree["parameters/conditions/death"] = false
	
	
	if !take_aim(): 
		state = MOVEMODE.CHASING # SET TO CHASING
		aim_build_up = 0
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/move"] = true
		animation_tree["parameters/conditions/death"] = false
		return

	aim_build_up += delta
	if aim_build_up >= aim_duration:
		
		animation_tree["parameters/conditions/attack"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/move"] = false
		animation_tree["parameters/conditions/death"] = false
		animation_tree["parameters/Attack/blend_position"] = velocity.normalized()
		shoot()
		aim_build_up = 0

# Aim at the player, return true if player is in range and unobstructed
func take_aim() -> bool:
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
	
	return true

func shoot() -> void:
	var direction = ((player.global_position + player.velocity * lead_time) - global_position).angle()
	
	var new_bullet:Projectile_2 = bullet.instantiate()
		
	new_bullet.init(global_position, direction)
	get_tree().root.add_child(new_bullet)
	# Play sound effect
	RangerShootAudio.play()
	#emit shoot signal for listeners
	ranger_shoot.emit()

func handle_waiting_state() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	if distance_to_player > aggro_range:
		state = MOVEMODE.CHASING
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/move"] = true
		animation_tree["parameters/conditions/death"] = false

func _on_Timer_timeout():
	state = MOVEMODE.AIMING
	animation_tree["parameters/conditions/attack"] = false
	animation_tree["parameters/conditions/idle"] = true
	animation_tree["parameters/conditions/move"] = false
	animation_tree["parameters/conditions/death"] = false

func take_damage(damage_taken: float) -> void:
	current_hp -= damage_taken
	# $AnimationPlayer.play("damage")
	# $Sprite.modulate = Color.RED # Maybe?
	# Play sound effect
	RangerDamageAudio.play()
	if dead:
		return
	elif current_hp <= 0:
		dead = true
		die()
	else:
		$RangerSpriteSheet.modulate = Color.RED
		await get_tree().create_timer(3/60.0).timeout
		$RangerSpriteSheet.modulate = Color.WHITE

func take_knockback(displacement: Vector2) -> void:
	pass

func die() -> void:
	SpawnRef.EnemyDie()
	
	set_physics_process(false)
	# Trigger death animation
	#$Ranger_AnimationP.play("Ranger_Death")
	animation_tree["parameters/conditions/attack"] = false
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/move"] = false
	animation_tree["parameters/conditions/death"] = true
	# Play sound effect
	RangerDeathAudio.play()
	# Emit a death signal, useful for later
	#emit_signal("enemy_died")
	await $Ranger_AnimationTree.animation_finished
	queue_free()
		
func call_ranger_move() -> void:
	RangerMoveAudio.play()
