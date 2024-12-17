extends Control


func _back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")
