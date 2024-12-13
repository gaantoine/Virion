extends TileMapLayer

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	randomize_tiles()

func randomize_tiles():
	# Ensure the TileSet is set for this TileMapLayer
	if not has_method("get_tile_set") or get_tile_set() == null:
		print("Error: TileSet not found or method 'get_tile_set' not available.")
		return

	var tileset = get_tile_set()

	# Iterate over used cells and store their positions
	var cell_positions = get_used_cells()

	# Get all tile IDs from the TileSet (assuming you know the maximum ID)
	var max_tile_id = 1000 # Replace with the actual maximum tile ID or a safe upper limit
	var tile_ids = []
	for id in range(max_tile_id):
		if tileset.tile_get_region(id) != Rect2():
			tile_ids.append(id)

	# Randomize tiles
	for cell_position in cell_positions:
		# Randomize isOuter tiles among themselves
		var outer_tiles = []
		var inner_tiles = []
		for tile_id in tile_ids:
			# Example condition to separate tiles, adjust as needed
			if tileset.tile_get_region(tile_id).size.x < tileset.tile_get_region(tile_id).size.y:
				outer_tiles.append(tile_id)
			else:
				inner_tiles.append(tile_id)

		if rng.randf() < 0.5: # Randomly choose between isOuter and isInner
			var num = rng.randi_range(0, outer_tiles.size() - 1)
			set_cell(cell_position, outer_tiles[num])
		else:
			var num = rng.randi_range(0, inner_tiles.size() - 1)
			set_cell(cell_position, inner_tiles[num])
