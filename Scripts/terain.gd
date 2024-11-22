extends TileMapLayer

@export var main_camera: Camera2D
@export var terrain_dirt: TileMapLayer

# Atlas tiles cords
var dirt_cell_cords: Vector2 = Vector2(1, 14)
var grass_cell_cords: Vector2 = Vector2(1, 13)
var dirt_background_cell_cords: Vector2 = Vector2(1,2)
var gold_cell_cords: Vector2 = Vector2(14, 4)
var rock_cell_cords: Vector2 = Vector2(14, 3)
var dig_animation_cell_cords: Vector2 = Vector2(5, 2)

const TERRAIN_SIZE = 500 # (1000x1000)

var cells_data: Array = []
var current_index: int = 0;

var rock_update_array: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_render_tilemap()
	SignalBus.update_grid_data.connect(_on_update_grid_recieved)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_tile_change()

func _on_update_grid_recieved(data: Dictionary) -> void:
	cells_data = data.get("cells", {})

func init_render_tilemap() -> void:
	for x in TERRAIN_SIZE:
		self.set_cell(Vector2(x, -1), 1, grass_cell_cords)
		for y in TERRAIN_SIZE:
			self.set_cell(Vector2(x, -y - 2), 1, Vector2(12, 6))
			self.set_cell(Vector2(x, y), 1, dirt_cell_cords)
	if (main_camera):
		main_camera.on_grid_rendered()

func process_tile_change(chunk_size: int = 100):
	if (cells_data.is_empty()):
		return
	
	var processed_count: int = 0
	while processed_count < chunk_size && current_index < cells_data.size():
		var cell = cells_data[current_index]
		set_dirt_tile(cell)
		current_index += 1
		processed_count += 1
	if (current_index >= cells_data.size()):
		current_index = 0
	apply_tiles()

func apply_tiles():
	terrain_dirt.set_cells_terrain_connect(rock_update_array,0,1, false)
	rock_update_array.clear()

func set_dirt_tile(cell: Dictionary) -> void:
	var cords = Vector2i(cell["x"], cell["y"])
	match (cell["type"]):
		CellType.EMPTY:
			terrain_dirt.erase_cell(cords)
		CellType.ROCK:
			rock_update_array.append(cords)
			#terrain_dirt.set_cell(cords, 1, dirt_background_cell_cords)
		CellType.TREASURE:
			terrain_dirt.set_cell(cords, 1, gold_cell_cords)
