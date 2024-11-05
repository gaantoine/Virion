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

var move_mode := MOVEMODE.WALKING
var can_dodge := true

var attr_defaults:Dictionary # string -> int
var attrs:Dictionary # string -> int
var attr_mods:Dictionary # string -> array[string]

func _ready():
	current = self

func _physics_process(delta:float) -> void:
	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	# movement functions test validity of a move action and perform it if necessary
	move_dodge(move_dir)
	move_walk(delta, move_dir)
	
	regen_energy(delta)	
	
	move_and_slide()

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
	collision_layer &= ~5 # make player invisible to collision layer 5 (enemies and damage search for the player on this layer)
	$Sprite2D.modulate = Color(0, 1, 0.5, 0.5) # placeholder dodge effect
	can_dodge = false
	# print(can_dodge)
	
	# return to normal movement
	await get_tree().create_timer(dodge_time).timeout
	move_mode = MOVEMODE.WALKING
	velocity = velocity.limit_length(max_speed)
	collision_layer |= 5 # re-enable enemy collision detection
	$Sprite2D.modulate = Color(1, 0.5, 0.5)
	
	# reset dodge
	await get_tree().create_timer(maxf(0, dodge_cooldown - dodge_time)).timeout
	can_dodge = true
	$Sprite2D.modulate = Color.WHITE

func use_energy(amount:float = 1) -> bool:
	if energy >= amount:
		energy -= amount
		$EnergyRegenDelayTimer.start(energy_regen_delay)
		return true
	return false

func regen_energy(delta:float) -> void:
	if $EnergyRegenDelayTimer.is_stopped():
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
		while i < len(mod_list) and mod_prio(mod_list[i]) > prio:
			i += 1
		mod_list.insert(i, mod)
		
		print(key," ",mods[key])
	pass

func apply_mods() -> void:
	pass

func mod_prio(mod:String) -> int:
	if mod[0] in "+-":
		if mod[-1] == "%":
			return 2
		return 1
	if mod[0] == "=":
		return 0
	push_error("invalid mod format: ", mod)
	return -1
