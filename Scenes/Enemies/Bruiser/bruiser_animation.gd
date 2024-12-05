extends Node2D

@export var animation_tree: AnimationTree
@onready var enemy:= get_owner()

# This variable is used to determine whether the 
var last_facing_direction := Vector2(0,-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	var wait = !enemy.velocity
	
	if !wait:
		last_facing_direction = enemy.velocity.normalized()
	
	animation_tree.set("parameters/conditions/wait", wait)
	animation_tree.set("parameters/conditions/chase", !wait)
	#Still working out the kinks on the dash animation
	#animation_tree.set("parameters/conditions/dash", dash)
	
	#These all use the current velocity to determine the blend position.
	#This makes sure the bruiser faces down or up when moving in the respective direction.
	animation_tree.set("parameters/Chase/blend_position", last_facing_direction)
	animation_tree.set("parameters/Wait/blend_position", last_facing_direction)
	#Still working out the kinks on the dash animation
	#animation_tree.set("parameters/Dash/blend_position", last_facing_direction)
