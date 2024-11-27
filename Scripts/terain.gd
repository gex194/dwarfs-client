extends TileMapLayer

@export var main_camera: Camera2D
@export var terrain_dirt: TileMapLayer

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
		self.set_cell(Vector2(x, -1), 1, CellTypeCords.GRASS)
		for y in TERRAIN_SIZE:
			self.set_cell(Vector2(x, -y - 2), 1, Vector2(12, 6))
			self.set_cell(Vector2(x, y), 1, CellTypeCords.ROCK)
	if (main_camera):
		main_camera.on_grid_rendered()

func process_tile_change(chunk_size: int = 100):
	if (cells_data.is_empty()):
		return
	
	var processed_count: int = 0
	while processed_count < chunk_size && current_index < cells_data.size():
		var cell = cells_data[current_index]
		TerrainHelper.set_dirt_tile(cell, terrain_dirt)
		current_index += 1
		processed_count += 1
	if (current_index >= cells_data.size()):
		current_index = 0
	apply_tiles()

func apply_tiles():
	terrain_dirt.set_cells_terrain_connect(rock_update_array,0,1, false)
	rock_update_array.clear()
