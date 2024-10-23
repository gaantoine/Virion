extends CharacterBody2D

@export var max_speed:float = 300
@export var accel_ratio:float = 4


func _physics_process(delta:float) -> void:
	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	movement_process(delta, move_dir)
	
	move_and_slide()



func movement_process(delta:float, move_dir:Vector2) -> void:	
	# math for exponential decay for movement decel
	var friction_exp:float = exp(-accel_ratio)
	var accel:Vector2 = move_dir * max_speed * accel_ratio * delta
	var decay:float = friction_exp ** delta
	
	velocity *= decay
	velocity += accel * (decay - 1) / log(decay) # integrate decay over acceleration interval instead of approximating with `accel * decay`
	
