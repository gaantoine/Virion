extends Node
class_name RoomFunc

@export var NextHallway: DoorFunc
@export var PrevHallway: DoorFunc
@export var Spawners: Array[SpawnerFunc]
var NumEnemies = 0
var Entered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func EnteredRoom(body: Node2D) -> void:
	if Entered == true or body.name != "Player":
		return
		
	Entered = true
	
	NextHallway.CloseDoor()
	PrevHallway.CloseDoor()
	
	for spawns in Spawners:
		spawns.SpawnEnemies()


func EnemiesKilled() -> void:
	if NumEnemies > 0:
		return
	
	NextHallway.OpenDoor()
	PrevHallway.OpenDoor()
	pass
