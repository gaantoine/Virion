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
## Max number of consecutive dodges
@export var max_energy:float = 4
## Rate at which energy regenerates per second.
@export var energy_regen_rate:float = 1
## Delay (in seconds) after consuming energy before regeneration resumes. 
@export var energy_regen_delay:float = 1

@onready var energy:float = max_energy

@onready var t_EnergyRegenDelay:Timer = $EnergyRegenDelayTimer
@onready var t_Refire:Timer = $RefireTimer

var sc_bullet := preload("res://Scenes/PlayerCharacter/bullet.tscn")

var move_mode := MOVEMODE.WALKING
var can_dodge := true

var attr_defaults:Dictionary # string -> int
var attrs:Dictionary # string -> int
var attr_mods:Dictionary # string -> array[string]

# Renzo -- This will store the tilemaps the player is colliding with
var collidingTileMaps:Array = []

func try_shoot():
	if Input.is_action_pressed("shoot") and t_Refire.is_stopped():
		t_Refire.start(1)
		var new_bullet:Bullet = sc_bullet.instantiate()
		new_bullet.global_position = global_position
		get_tree().root.add_child(new_bullet)

func _ready():
	current = self
	attr_defaults = {
		"bullet_damage": 5,
		"bullet_speed": 1,
		"bullet_range": 5,
		"bullet_firing_rate": 1,
		"bullet_piercing": 0,
		"bullet_count": 1,
		"bullet_arc": 0, # for multi-shot weapons
		"melee_damage": 5,
		"consumable_damage": 5,
		"consumable_size": 1,
		"droprate_grenade": 1,
		"droprate_firebomb": 1,
		"droprate_stun": 1,
		"dodge_speed": 1,
		"stamina": 4
	}
	
	attrs = attr_defaults.duplicate()

func _physics_process(delta:float) -> void:
	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	# movement functions test validity of a move action and perform it if necessary
	move_dodge(move_dir)
	move_walk(delta, move_dir)
	
	regen_energy(delta)	
	
	try_shoot()
	
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_focus_next"): # mod system testing
		print(attrs["bullet_firing_rate"])
		#attr_defaults = {"fire_rate": 10, "bullet_damage": 5}
		#add_mods({"fire_rate": "=5", "bullet_damage": "+20%"})
		#add_mods({"fire_rate": "+1"})
		#add_mods({"fire_rate": "-50%"})
		#apply_mods()
		#print("fire_rate: ", attrs["fire_rate"])
		#print("damage: ", attrs["bullet_damage"])
		
	# Renzo -- It will detect tile map collision and if Custom Data "is_destructive" is true, it will destroy player
	for collider in collidingTileMaps:
		var tile_pos = collider.local_to_map(collider.to_local(global_position))
		var tile_data = collider.get_cell_tile_data(tile_pos)
		
		if tile_data and tile_data.get_custom_data("is_destructive"):
			destroy_player()

	# Renzo -- Spike Collision Event
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is TileMapLayer:
			
			var tile_pos = collider.local_to_map(collider.to_local(get_slide_collision(i).get_position()-get_slide_collision(i).get_normal()))
			var tile_data = collider.get_cell_tile_data(tile_pos)
			
			if tile_data and tile_data.get_custom_data("is_destructive"):
				print("damaging player")
				velocity = get_slide_collision(i).get_normal()*1000

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
	collision_layer &= ~(1<<5) # make player invisible to collision layer 5 (enemies and damage search for the player on this layer)
	$CollisionShape2D.debug_color = Color(0, 1, 0.5, 0.5) # placeholder dodge effect
	can_dodge = false
	# print(can_dodge)
	
	# return to normal movement
	await get_tree().create_timer(dodge_time).timeout
	move_mode = MOVEMODE.WALKING
	velocity = velocity.limit_length(max_speed)
	collision_layer |= (1<<5) # re-enable enemy collision detection
	$CollisionShape2D.debug_color = Color(1, 0.5, 0.5, 0.5)
	
	# reset dodge
	await get_tree().create_timer(maxf(0, dodge_cooldown - dodge_time)).timeout
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

func add_mods(mods:Dictionary) -> void:
	for key in mods:
		var mod:String = mods[key]
		var prio:int = mod_prio(mod)
		if not attr_mods.has(key):
			attr_mods[key] = []
		var mod_list:Array = attr_mods[key]
		var i:int = 0
		while i < len(mod_list) and mod_prio(mod_list[i]) < prio:
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
					attrs[attr] = int(mod)
			else:
				if mod[-1] == "%":
					attrs[attr] += attrs[attr] * int(mod.left(-1)) / 100.0
				else:
					attrs[attr] += int(mod)

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
	pass # Replace with function body.
