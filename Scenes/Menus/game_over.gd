extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func btn_retry() -> void:
	get_tree().reload_current_scene()


func btn_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")