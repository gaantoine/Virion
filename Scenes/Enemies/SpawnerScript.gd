extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func SpawnEnemies() -> void:
	var holdEnemy = load("res://Scenes/Enemies/Bruiser/EnemyBruiser.tscn").instantiate()
	self.add_child(holdEnemy)
	holdEnemy.global_position = self.global_position
