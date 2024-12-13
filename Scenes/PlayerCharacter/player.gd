extends CharacterBody2D
class_name Player

enum MOVEMODE {
	WALKING,
	DODGING
}

static var current:Player

@export_category("Walking")
## Top movement speed of character, pixels/second
@export var max_speed:float = 300
## How fast the player gets up to speed compared to the max speed. Lower value for floatiness, raise it for snappiness.
@export var accel_ratio:float = 12

@export_category("Dodging")
## Travel distance of dodge
@export var dodge_range:float = 150
## Duration of dodge travel and iframes, in seconds.
@export var dodge_time:float = 0.2
## Cooldown between dodge uses in seconds. Starts when the dodge is triggered, not when it ends.
@export var dodge_cooldown:float = 0.75

@export_category("Energy")
## Rate at which energy regenerates per second.
@export var energy_regen_rate:float = 1
## Delay (in seconds) after consuming energy before regeneration resumes.
@export var energy_regen_delay:float = 1

var max_energy:float:
	get: return attrs["stamina"]

@onready var energy:float = 4

@onready var t_EnergyRegenDelay:Timer = $EnergyRegenDelayTimer

@onready var c_healthbar:ProgressBar = $CanvasLayer/AspectRatioContainer/HealthContainer/Healthbar
@onready var c_graybar:ProgressBar = $CanvasLayer/AspectRatioContainer2/GrayContainer/GrayHealth

@onready var animation_tree : AnimationTree = $Nebula_AnimationTree

var move_mode := MOVEMODE.WALKING
var can_dodge := true


@export_category("Health and Damage")
## Total player Health
@export var health:float = 100
var max_hp:float = 100
var GRAY_COEFF:float = 0.5
var LIFESTEAL_RATIO:float = 0.1
## The duration of the immunity window after taking damage
@export var immunity_duration:float = 0.5
var is_immune:bool = false

@export_category("Player Base Attributes")
@export var attr_defaults:Dictionary = {
	"bullet_damage": 5,
	"bullet_speed": 1, # tiles per second
	"bullet_range": 10, # in tiles
	"bullet_size": 1,
	"bullet_firing_rate": 1,
	"bullet_accuracy": 1,
	"bullet_piercing": 1,
	"bullet_count": 1,
	"bullet_arc": 10, # for multi-shot weapons
	"melee_damage": 5,
	"melee_knockback": 2,
	#"consumable_damage": 5,
	#"consumable_size": 1,
	#"droprate_grenade": 1,
	#"droprate_firebomb": 1,
	#"droprate_stun": 1,
	"dodge_speed": 1,
	"stamina": 4
}

var attrs:Dictionary # string -> int
var attr_mods:Dictionary # string -> array[string]

# Renzo -- This will store the tilemaps the player is colliding with
var collidingTileMaps:Array = []

#signal variable for player footsteps called in Animation Player
signal player_footstep
#signal variable for player dodge start called in Animation Player
signal player_dodge_start
#signal variable for player dodge end called in Animation Player
signal player_dodge_end

func _ready():
	animation_tree.active = true
	current = self

	attrs = attr_defaults.duplicate()

func _physics_process(delta:float) -> void:

	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	# movement functions test validity of a move action and perform it if necessary
	move_dodge(move_dir)
	move_walk(delta, move_dir)

	regen_energy(delta)

	move_and_slide()

	if Input.is_action_just_pressed("ui_focus_next"): # mod system testing
		print(attrs["bullet_firing_rate"])

	# Renzo -- It will detect tile map collision and if Custom Data "is_destructive" is true, it will destroy player
	for layer:TileMapLayer in collidingTileMaps:
		var tile_pos:Vector2i = layer.local_to_map(layer.to_local(global_position))
		var tile_data:TileData = layer.get_cell_tile_data(tile_pos)

		if tile_data and tile_data.get_custom_data("is_destructive"):
			destroy_player()

	# Renzo -- Spike Collision Event
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is TileMapLayer:
			var tile_pos = collider.local_to_map(collider.to_local(get_slide_collision(i).get_position()-get_slide_collision(i).get_normal()))
			var tile_data = collider.get_cell_tile_data(tile_pos)

			if tile_data and tile_data.get_custom_data("is_destructive"):
				take_damage(5)

func move_walk(delta:float, move_dir:Vector2) -> void:
	if move_mode != MOVEMODE.WALKING:
		return

	# math for exponential decay for movement decel
	var accel:Vector2 = move_dir * max_speed * accel_ratio * delta
	var decay:float = exp(-accel_ratio * delta) # exponential decay per second for speed limiting, turning, and deceleration

	# apply decay then movement accel
	velocity *= decay
	velocity += accel * (decay - 1) / log(decay) # integrate decay over acceleration interval instead of approximating with `accel * decay`

func move_dodge(move_dir:Vector2) -> void:
	if move_mode != MOVEMODE.WALKING:
		return
	if not Input.is_action_pressed("dodge"):
		return
	if move_dir == Vector2.ZERO:
		return
	if not can_dodge:
		return
	if not use_energy():
		return

	# initiate dodge
	move_mode = MOVEMODE.DODGING
	velocity = move_dir * dodge_range / dodge_time
	set_collision_layer_value(6, false) # make player invisible to collision layer 6 (enemies and damage search for the player on this layer)
	$CollisionShape2D.debug_color = Color(0, 1, 0.5, 0.5) # placeholder dodge effect
	can_dodge = false

	# return to normal movement
	await get_tree().create_timer(dodge_time).timeout
	move_mode = MOVEMODE.WALKING
	velocity = velocity.limit_length(max_speed)
	set_collision_layer_value(6, true) # re-enable enemy collision detection
	$CollisionShape2D.debug_color = Color(1, 0.5, 0.5, 0.5)

	# reset dodge
	await get_tree().create_timer(maxf(0, dodge_cooldown / attrs["dodge_speed"] - dodge_time)).timeout
	can_dodge = true
	$CollisionShape2D.debug_color = Color(0, 0.6, 0.69, 0.41)

func use_energy(amount:float = 1) -> bool:
	if energy >= amount:
		energy -= amount
		t_EnergyRegenDelay.start(energy_regen_delay)
		return true
	return false

func regen_energy(delta:float) -> void:
	if t_EnergyRegenDelay.is_stopped():
		energy = min(max_energy, energy + delta * energy_regen_rate)
	$EnergyLabel.text = str(int(energy))

func regen_health(damage:float) -> void:
	health += damage * LIFESTEAL_RATIO
	if health > max_hp:
		health = max_hp
	update_health_display()

func take_damage(damage:float) -> void:
	if is_immune:
		return
	
	health -= damage
	max_hp -= damage * GRAY_COEFF
	modulate = Color.RED
	update_health_display()
	if health <= 0:
		health = 0
		die()
	else:
		create_tween().tween_property(self, "modulate", Color.WHITE, 6.0/60)
		start_immunity()

func start_immunity() -> void:
	is_immune = true
	await get_tree().create_timer(immunity_duration).timeout
	is_immune = false

func update_health_display() -> void:
	c_healthbar.value = health
	c_graybar.value = max_hp


func die() -> void:
	print("aaaaaaaa dying dying dying")

func add_mods(mods:Dictionary) -> void:
	for key in mods:
		var mod:String = mods[key]
		var prio:int = mod_prio(mod)
		if not attr_mods.has(key):
			attr_mods[key] = []
		var mod_list:Array = attr_mods[key]
		var i:int = 0
		while i < len(mod_list) and mod_prio(mod_list[i]) <= prio:
			i += 1
		mod_list.insert(i, mod)
	apply_mods()

func apply_mods() -> void:
	attrs = attr_defaults.duplicate()
	for attr in attr_mods:
		var mod_list:Array = attr_mods[attr]
		for mod in mod_list:
			if mod[0] == "=":
				mod = mod.right(-1)
				if mod[-1] == "%":
					attrs[attr] *= int(mod.left(-1)) / 100.0
				else:
					attrs[attr] = float(mod)
			else:
				if mod[-1] == "%":
					attrs[attr] += attrs[attr] * int(mod.left(-1)) / 100.0
				else:
					attrs[attr] += float(mod)

func mod_prio(mod:String) -> int:
	if mod[0] in "+-":
		if mod[-1] == "%":
			return 2
		return 1
	if mod[0] == "=":
		return 0
	push_error("invalid mod format: ", mod)
	return -1



# Renzo -- Pit Collision Event

func destroy_player() -> void:
	# Implement player destruction logic here
	print("Player destroyed by destructive tile!")
	# You might want to add effects, play a sound, or transition to a game over screen
	# For example:
	# $DeathSound.play()
	# $DeathParticles.emitting = true
	# await get_tree().create_timer(1.0).timeout
	# get_tree().change_scene_to_file("res://game_over.tscn")
	queue_free()


func _on_area_2d_body_entered(collider: Node2D) -> void:
	if collider is TileMapLayer:
		collidingTileMaps.append(collider)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		collidingTileMaps.erase(body)

#This function is triggered from the animation player to call for footsteps sounds
#from the audio manager when specific frames of animation are played
func call_player_footstep() -> void:
	player_footstep.emit()

#This function is triggered from the animation player to call for the dodge jump sound
#from the audio manager when specific frames of animation are played
func call_player_dodge_start() -> void:
	player_dodge_start.emit()

#This function is triggered from the animation player to call for the dodge land sound
#from the audio manager when specific frames of animation are played
func call_player_dodge_end() -> void:
	player_dodge_end.emit()

func _process(_delta):
	update_animation_parameters()

func update_animation_parameters():
	if(move_mode == MOVEMODE.WALKING):
		animation_tree["parameters/conditions/walk"] = true
		animation_tree["parameters/conditions/dodging"] = false
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/Walk/blend_position"] = velocity.normalized()
	if(move_mode == MOVEMODE.WALKING and Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized() == Vector2.ZERO):
		animation_tree["parameters/conditions/walk"] = false
		animation_tree["parameters/conditions/dodging"] = false
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/Idle/blend_position"] = velocity.normalized()
	if(move_mode == MOVEMODE.DODGING):
		animation_tree["parameters/conditions/walk"] = false
		animation_tree["parameters/conditions/dodging"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/Rolling/blend_position"] = velocity.normalized()
		
		#animation_tree["parameters/Walk/blend_position"] = velocity.normalized()
		#animation_tree["parameters/Rolling/blend_position"] = velocity.normalized()
		#animation_tree["parameters/Idle/blend_position"] = velocity.normalized()

func In_Combat() -> void:
	print("combatmode")
	pass

func Out_Combat() -> void:
	print("outcombat")
	pass
