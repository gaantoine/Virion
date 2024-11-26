extends Node

@export var StartRoom: Node2D
@export var MaxRooms: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CreateRooms(MaxRooms)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func CreateRooms(limit: int) -> void:
	var exit = StartRoom.find_child("Exit").global_position
	var nextRoom = preload("res://Scenes/Rooms/InbetweenRooms.tscn").instantiate()
	StartRoom.add_child(nextRoom)
	nextRoom.global_position = exit
	
	
