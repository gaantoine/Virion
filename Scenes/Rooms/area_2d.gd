extends Area2D


var entered = false;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if entered == true:
		get_tree().change_scene_to_file("res://Scenes/Rooms/Room2.tscn")
	pass


func _on_body_entered(body: PhysicsBody2D) -> void:
	entered = true;
	pass # Replace with function body.


func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	entered = false
	pass # Replace with function body.
