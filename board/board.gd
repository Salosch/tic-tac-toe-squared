extends TileMap

class_name Board

var tile_by_name := {}
var layer_by_name := {}

var unique_item_pos: Vector2 = Vector2(-1,-1)

var board_winner: String = ""

@export var state_layer: String = "States"
@export var board_layer: String = "Board"
@export var state_name: String = "Name"
@export var empty_state: String = "Empty"
var off_limits: String = ""
@export var active: bool = true

func _ready():
	print("Initializing board...")
	_index_atlas_coordinates_by_name()
	_index_layers_by_name()
	$Highlight.size = tile_set.tile_size
	print("Tiles: ", ", ".join(tile_by_name.keys()))
	assign_unique_item()
	
func assign_unique_item():
	var empty_cells = []
	for cell in get_used_cells(layer_by_name[board_layer]):
		if get_state(cell) == empty_state:
			empty_cells.append(cell)
	if empty_cells.size() > 0:
		unique_item_pos = empty_cells[randi() % empty_cells.size()]
	print("Position Item: ", unique_item_pos)

func check_board_win():
	for cell in get_used_cells(layer_by_name[state_layer]):
		var state = get_state(cell)
		if state == empty_state:
			continue 
		for check in _checks:
			var same = true
			for neighbour in check:
				var neighbour_state = get_state(cell + neighbour)
				if neighbour_state != state:
					same = false
					break
			if same:
				board_winner = state
				return true
	return false

func get_state(grid_pos: Vector2) -> String:
	var state_tile_data: TileData = self.get_cell_tile_data(layer_by_name[state_layer], grid_pos)
	var board_tile_data: TileData = self.get_cell_tile_data(layer_by_name[board_layer], grid_pos)
	if not board_tile_data:
		return off_limits
	if not state_tile_data or not state_tile_data.get_custom_data(state_name):
		return empty_state
	return state_tile_data.get_custom_data(state_name)

func set_state(grid_pos: Vector2, state: String) -> bool:
	if get_state(grid_pos) != empty_state:
		return false
	self.set_cell(layer_by_name[state_layer], grid_pos, tile_by_name[state]["source_id"], tile_by_name[state]["atlas_coords"])
	return true

func global_to_map(global_pos: Vector2) -> Vector2:
	return self.local_to_map(self.to_local(global_pos))

func gridpos_at_mouse() -> Vector2:
	return global_to_map(get_viewport().get_mouse_position())

func reset() -> void:
	for cell in get_used_cells(layer_by_name[state_layer]):
		set_cell(layer_by_name[state_layer], cell, -1)
	board_winner = ""
	if self.hidden:
		self.show()

func _index_atlas_coordinates_by_name():
	var tileset = self.tile_set
	for source_index in range(tileset.get_source_count()):
		var source_id = tileset.get_source_id(source_index)
		var atlas:TileSetAtlasSource = tileset.get_source(source_id)
		for tile_index in range(atlas.get_tiles_count()):
			var atlas_coords = atlas.get_tile_id(tile_index)
			var tile_data : TileData = atlas.get_tile_data(atlas_coords, 0)
			if tile_data and tile_data.get_custom_data(state_name):
				tile_by_name[tile_data.get_custom_data(state_name)] = {
					"source_id": source_id,
					"atlas_coords": atlas_coords
				}

func _index_layers_by_name():
	for i in range(get_layers_count()):
		layer_by_name[get_layer_name(i)] = i

var _checks = [
	[Vector2i(-1,0), Vector2i(1,0)],
	[Vector2i(0,-1), Vector2i(0,1)],
	[Vector2i(-1,-1), Vector2i(1,1)],
	[Vector2i(-1,1), Vector2i(1,-1)],
]
