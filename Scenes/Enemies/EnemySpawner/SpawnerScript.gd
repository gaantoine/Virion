extends Node
class_name SpawnerFunc

@export var TheEnemy: PackedScene
@export var TheRoom: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func SpawnEnemies() -> void:
	var holdEnemy = load(TheEnemy.resource_path).instantiate()
	self.add_child(holdEnemy)
	holdEnemy.global_position = self.global_position
	holdEnemy.SpawnRef = self
	TheRoom.NumEnemies += 1


func EnemyDie() -> void:
	TheRoom.NumEnemies -= 1
	TheRoom.EnemiesKilled()


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
