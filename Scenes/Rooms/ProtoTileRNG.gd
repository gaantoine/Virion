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

	# Get all tile IDs from the TileSet
	var tile_ids = []
	for id in tileset.get_tiles_ids():
		tile_ids.append(id)

	# Separate tiles based on custom data
	var inner_tile_id = -1
	var outer_tile_id = -1
	for tile_id in tile_ids:
		var tile_data = tileset.tile_get_tile_data(tile_id)
		if tile_data.get_custom_data("isInner"):
			inner_tile_id = tile_id
		elif tile_data.get_custom_data("isOuter"):
			outer_tile_id = tile_id

	# Iterate over used cells and store their positions
	var cell_positions = get_used_cells()

	# Randomize tiles
	for cell_position in cell_positions:
		var current_tile_id = get_cell_source_id(cell_position)
		var tile_data = tileset.tile_get_tile_data(current_tile_id)

		if tile_data.get_custom_data("isInner"):
			# Randomly select the inner tile or make it invisible
			set_cell(cell_position, inner_tile_id if rng.randf() < 0.5 else -1)
		elif tile_data.get_custom_data("isOuter"):
			# Randomly decide if the outer tile stays visible or becomes invisible
			set_cell(cell_position, outer_tile_id if rng.randf() < 0.5 else -1)

	# Optional: Ensure that at least one inner tile remains visible if desired
	# This is to prevent all inner tiles from becoming invisible
	var has_visible_inner = false
	for cell_position in cell_positions:
		var tile_id = get_cell_source_id(cell_position)
		var tile_data = tileset.tile_get_tile_data(tile_id)
		if tile_data.get_custom_data("isInner") and tile_id != -1:
			has_visible_inner = true
			break
	if not has_visible_inner:
		for cell_position in cell_positions:
			var tile_id = get_cell_source_id(cell_position)
			var tile_data = tileset.tile_get_tile_data(tile_id)
			if tile_data.get_custom_data("isInner"):
				set_cell(cell_position, inner_tile_id)
				break
