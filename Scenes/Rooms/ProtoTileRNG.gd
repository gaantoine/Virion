extends TileMapLayer

func _ready() -> void:
	# Generate a random number between 0 and 1
	var random_visibility = randf()
	
	# Decide visibility based on the random value
	if random_visibility < 0.5: # 50% chance of being visible
		enable_layer()
	else:
		disable_layer()

func enable_layer() -> void:
	set_enabled(true)

func disable_layer() -> void:
	set_enabled(false)
