extends Area2D

var player_in_range = false
var dialog_displayed_counter = 0
var dialog: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog = load_dialog_data("res://Scenes/NPCs/Dialog.json")
	dialog_displayed_counter = 0
	pass # Replace with function body.

# Load the JSON data from a file
func load_dialog_data(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var data = file.get_as_text()

		var json = JSON.new()
		var result = json.parse(data)
		if result == OK:
			return json.data  
		else:
			print("Error parsing JSON:", json.error_message())
			return {}
	else:
		print("File does not exist or cannot be opened:", file_path)
		return {}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !player_in_range:
		return
	
	if Input.is_action_just_pressed("interact"):
		print(dialog["1"][dialog_displayed_counter])
		dialog_displayed_counter = (dialog_displayed_counter + 1) % dialog["1"].size()

func _on_body_entered(body):
	if body == Player.current:
		player_in_range = true
		print("entered")


func _on_body_exited(body):
	if body == Player.current:
		player_in_range = false
		print("exited")
