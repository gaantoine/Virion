# Renzo -- TileMapLayer Random Variation
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
	set_visible(true)
	_sync_child_visibility(true)

func disable_layer() -> void:
	set_visible(false)
	_sync_child_visibility(false)

func _sync_child_visibility(visible: bool) -> void:
	for child in get_children():
		if child is Node:
			child.set_visible(visible)
