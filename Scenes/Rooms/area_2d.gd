extends Area2D


var entered = false;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	if entered == true:
		get_tree().change_scene_to_file("res://Scenes/Rooms/Room2.tscn")


func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("player"):
		entered = true;

func _on_body_shape_exited(_body_rid:RID, body:Node2D, _body_shape_index:int, _local_shape_index:int) -> void:
	if body.is_in_group("player"):
		entered = false
