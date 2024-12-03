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
	
	animation_tree.set("parameters/Walk/blend_position", enemy.velocity.normalized())
	animation_tree.set("parameters/Charge/blend_position", enemy.velocity.normalized())
