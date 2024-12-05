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
	var previousHall = StartHallway  # Initialize with the starting hallway
	var saveHall = null  # Will be used to store the current room
	var allRooms = [1, 2, 3, 4, 5, 6]  # List of available room numbers -- ADD ROOMS HERE
	
	while (CurrentRooms < MaxRooms):
		# Get the exit position of the previous hallway
		var exitPos = previousHall.find_child("Exit").global_position
		
		# Pick a random room number and create the path to its scene
		var pickRand = allRooms.pick_random()
		var randomRoom = "res://Scenes/Rooms/Room" + str(pickRand) + ".tscn"
		
		# Instantiate the randomly selected room
		var holdRoom = load(randomRoom).instantiate()
		StartRoom.add_child(holdRoom)  # Add the room to the scene
		holdRoom.global_position = exitPos  # Set its position
		
		# Store the current room and set its previous hallway
		saveHall = holdRoom
		if "PrevHallway" in saveHall:  # Check if the property exists
			saveHall.PrevHallway = previousHall
		
		# Create and add the next hallway
		exitPos = holdRoom.find_child("Exit").global_position
		holdRoom = load("res://Scenes/Rooms/InbetweenRooms.tscn").instantiate()
		StartHallway.add_child(holdRoom)
		holdRoom.global_position = exitPos
		
		# Set the next hallway for the current room
		if "NextHallway" in saveHall:  # Check if the property exists
			saveHall.NextHallway = holdRoom
		
		# Update variables for the next iteration
		allRooms.erase(pickRand)  # Remove the used room number
		previousHall = holdRoom  # The current hallway becomes the previous for next iteration
		CurrentRooms += 1  # Increment the room count
	
	# Renzo - Add EndRoom after creating all regular rooms
	if CurrentRooms == MaxRooms:
		var exitPos = previousHall.find_child("Exit").global_position
		var endRoom = load("res://Scenes/Rooms/EndRoom.tscn").instantiate()
		StartRoom.add_child(endRoom)  # Add the EndRoom to the scene
		endRoom.global_position = exitPos  # Set its position
		
		# Set the previous hallway for the EndRoom if the property exists
		if "PrevHallway" in endRoom:
			endRoom.PrevHallway = previousHall
