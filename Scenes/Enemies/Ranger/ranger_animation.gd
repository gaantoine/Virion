extends Node2D

@export var animation_tree: AnimationTree
@onready var enemy:= get_owner()

# This variable is used to determine whether the 
var last_facing_direction := Vector2(0,-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	var idle = !enemy.velocity
	
	if !idle:
		last_facing_direction = enemy.velocity.normalized()
	
	animation_tree.set("parameters/conditions/idle", idle)
	#animation_tree.set("parameters/conditions/chase", !wait) Placeholder
	
	
	#These all use the current velocity to determine the blend position.
	#This makes sure the bruiser faces down or up when moving in the respective direction.
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
	#animation_tree.set("parameters/Wait/blend_position", last_facing_direction) Placeholder
	
