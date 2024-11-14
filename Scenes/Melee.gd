extends Node2D

# Define the melee attack cooldown time (in seconds)
var melee_cooldown = 1.0
var time_since_last_melee = 0.0

# Define the melee attack range and damage
var melee_range = 50.0
var melee_damage = 10

func _ready():
	# Initialize any necessary variables or states here
	pass

func _process(delta):
	# Update the time since the last melee attack
	time_since_last_melee += delta
	
	# Check for melee attack input and if enough time has passed since the last melee attack
	if Input.is_action_pressed("melee_attack") and time_since_last_melee >= melee_cooldown:
		perform_melee_attack()
		time_since_last_melee = 0.0

func perform_melee_attack():
	# Get all overlapping bodies within the melee range
	var bodies = get_overlapping_bodies_in_range(melee_range)
	
	# Apply damage to each body that is an enemy
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(melee_damage)

func get_overlapping_bodies_in_range(range):
	var overlapping_bodies = []
	
	# Create an area to detect overlapping bodies
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = range
	collision_shape.shape = shape
	area.add_child(collision_shape)
	
	# Add the area to the scene temporarily to detect overlaps
	add_child(area)
	area.set_global_position(global_position)
	
	# Get the overlapping bodies
	overlapping_bodies = area.get_overlapping_bodies()
	
	# Remove the temporary area from the scene
	remove_child(area)
	area.queue_free()
	
	return overlapping_bodies
