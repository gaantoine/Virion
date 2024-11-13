extends CharacterBody2D
class_name Bullet

@export var bullet_speed:float = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(get_global_mouse_position())
	velocity = bullet_speed * Vector2.RIGHT.rotated(global_rotation)
	#global_position = get_global_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	var collision:KinematicCollision2D = move_and_collide(velocity * delta)
	if collision != null:
		var object = collision.get_collider()
		if object is Node2D:
			var node:Node2D = object
			if node.is_in_group("enemy"):
				print("damage enemy: ", node.name)
		queue_free()
