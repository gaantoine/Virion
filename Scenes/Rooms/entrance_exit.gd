extends Area2D

var isInArea = false
@export var Doors: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isInArea:
		if Input.is_key_pressed(KEY_F):
			Doors.visible = false
			Doors.collision_enabled = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		isInArea = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		isInArea = false
		Doors.visible = true
		Doors.collision_enabled = true
