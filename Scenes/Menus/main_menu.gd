extends Control

func _ready() -> void:
	pass

func _exit_pressed() -> void:
	get_tree().quit()

func _credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/Credits.tscn")

func _play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Rooms/MainLevel.tscn")
