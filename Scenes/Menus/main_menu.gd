extends Control

func _ready() -> void:
	print("READYYYYYYYYY")

func _exit_pressed() -> void:
	print("aaaaaaaaaaaaa")
	get_tree().quit()

func _credits_pressed() -> void:
	pass # Replace with function body.

func _play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Rooms/MainLevel.tscn")
