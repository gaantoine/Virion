extends Node
class_name RoomFunc

@export var NextHallway: DoorFunc
@export var PrevHallway: DoorFunc
@export var ItemSpawn: BasePickup
@export var Spawners: Array[SpawnerFunc]
var ThePlayer
var NumEnemies = 0
var Entered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ThePlayer = Player.current
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func EnteredRoom(body: Node2D) -> void:
	if Entered == true or body.name != "Player":
		return
		
	Entered = true
	
	if NextHallway:
		NextHallway.CloseDoor()
	PrevHallway.CloseDoor()
	
	for spawns in Spawners:
		spawns.SpawnEnemies()
	
	ThePlayer.emit_signal("In_Combat")


func EnemiesKilled() -> void:
	if NumEnemies > 0:
		return
	
	if NextHallway:
		NextHallway.OpenDoor()
	PrevHallway.OpenDoor()
	
	ThePlayer.emit_signal("Out_Combat")

func _on_area_2d_body_entered(body: Node2D) -> void:
	#get_tree().reload_current_scene()
	#get_tree().reload("res://Scenes/Rooms/5Rooms.tscn")
	var oldPos = $"../..".global_position
	$"../..".queue_free()
	var newNode = load("res://Scenes/Rooms/5Rooms.tscn").instantiate()
	newNode.global_position = oldPos
	get_tree().root.add_child(newNode)
	print(ThePlayer.startPos)
	ThePlayer.global_position = ThePlayer.startPos
