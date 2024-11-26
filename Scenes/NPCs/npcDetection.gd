extends Area2D

var player_in_range = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !player_in_range:
		return
	
	if Input.is_action_just_pressed("interact"):
		print("blah blah blah")


func _on_body_entered(body):
	if body == Player.current:
		player_in_range = true
		print("entered")


func _on_body_exited(body):
	if body == Player.current:
		player_in_range = false
		print("exited")
