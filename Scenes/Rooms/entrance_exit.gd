extends Node2D
class_name DoorFunc

@export var Doors: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func OpenDoor() -> void:
	Doors.visible = false
	Doors.collision_enabled = false


func CloseDoor() -> void:
	Doors.visible = true
	Doors.collision_enabled = true
