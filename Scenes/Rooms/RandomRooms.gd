extends Node

@export var StartRoom: Node2D
@export var StartHallway: Node2D
@export var MaxRooms: int
@export var MaxSideRooms: int
@export var DebugRoom: int = -1
var CurrentRooms = 0
var SideRoomHold = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CreateRooms()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
		if DebugRoom != -1:
			pickRand = DebugRoom
		var randomRoom = "res://Scenes/Rooms/Room" + str(pickRand) + ".tscn"
		
		# Instantiate the randomly selected room
		var holdRoom = load(randomRoom).instantiate()
		StartRoom.add_child(holdRoom)  # Add the room to the scene
		holdRoom.global_position = exitPos  # Set its position
		SideRoomHold.append(holdRoom) # Add room to array of all rooms (for side rooms)
		
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
		if DebugRoom == -1:
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
	
	# Add side rooms randomly here
	# First, we can't have more side rooms than rooms
	MaxSideRooms -= 1
	if MaxSideRooms > MaxRooms:
		MaxSideRooms = MaxRooms
	
	# ALL THE SIDE ROOM STUFF HERE
	while (MaxSideRooms > -1):
		var LR = ""
		# Save a random room and it's side door position to add a side room later on
		var RandSide = SideRoomHold.pick_random()
		var LRSide # Redundant but it works, room positions are different based on left or right side
		if RandSide.find_child("RSideRoomDoor"):
			LRSide = RandSide.find_child("RSideRoomDoor")
			LR = "Right"
		else:
			LRSide = RandSide.find_child("LSideRoomDoor")
			LR = "Left"
		LRSide.visible = false # Also make the side doors not visible
		LRSide.collision_enabled = false
		
		# Create a side room path and put it in place
		var randomRoom = "res://Scenes/Rooms/SideRooms/SideRoomPath.tscn"
		var holdRoom = load(randomRoom).instantiate()
		StartHallway.add_child(holdRoom)
		var LROffset = 0
		if LR == "Left": # No exact positions so we need the offset to the right spot added on...
			LROffset = holdRoom.global_position - holdRoom.find_child("PathL").global_position
			holdRoom.global_position = LRSide.global_position + LROffset # ... which we add on here...
			LRSide = holdRoom.find_child("PathR")
		else:
			LROffset = holdRoom.global_position - holdRoom.find_child("PathR").global_position
			holdRoom.global_position = LRSide.global_position + LROffset # ... or here
			LRSide = holdRoom.find_child("PathL")
		
		# Now create a random side room and put it in the correct area
		randomRoom = "res://Scenes/Rooms/SideRooms/SideRoom" + str(randi_range(1, 3)) + ".tscn"
		holdRoom = load(randomRoom).instantiate()
		StartRoom.add_child(holdRoom)
		if LR == "Left": # No exact positions so we need the offset to the right spot added on...
			LROffset = holdRoom.global_position - holdRoom.find_child("DoorL").global_position
			holdRoom.find_child("DoorL").visible = false
			holdRoom.find_child("DoorL").collision_enabled = false
		else:
			LROffset = holdRoom.global_position - holdRoom.find_child("DoorR").global_position
			holdRoom.find_child("DoorR").visible = false
			holdRoom.find_child("DoorR").collision_enabled = false
		holdRoom.global_position = LRSide.global_position + LROffset
		
		SideRoomHold.erase(RandSide)
		MaxSideRooms -= 1
