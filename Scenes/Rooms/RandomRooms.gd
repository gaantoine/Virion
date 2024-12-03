extends Node

@export var StartRoom: Node2D
@export var StartHallway: Node2D
@export var MaxRooms: int
var CurrentRooms = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CreateRooms()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Ehmry Bay
func CreateRooms() -> void:
	var previousHall = StartHallway
	var saveHall = null
	var prevRoom = -1
	var allRooms = [1, 2, 3, 4, 5]
	
	while (CurrentRooms < MaxRooms):
		# Random room here
		var exitPos = previousHall.find_child("Exit").global_position
		var pickRand = allRooms.pick_random()
		var randomRoom = "res://Scenes/Rooms/Room" + str(pickRand) + ".tscn"
		var holdRoom = load(randomRoom).instantiate()
		StartRoom.add_child(holdRoom)
		holdRoom.global_position = exitPos
		saveHall = holdRoom
		saveHall.PrevHallway = previousHall
		
		# Add the hallway here
		exitPos = holdRoom.find_child("Exit").global_position
		holdRoom = load("res://Scenes/Rooms/InbetweenRooms.tscn").instantiate()
		StartHallway.add_child(holdRoom)
		holdRoom.global_position = exitPos
		saveHall.NextHallway = holdRoom
		
		allRooms = [1, 2, 3, 4, 5]
		allRooms.pop_at(allRooms.find(pickRand))
		previousHall = holdRoom
		MaxRooms -= 1
