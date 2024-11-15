extends Node2D

var StaticData = preload("res://Singletons/StaticData.gd")
@onready var Socket = get_node("WebsocketManager")
var Gnome = preload("res://Scenes/gnome.tscn")
@onready var terrain: TileMapLayer = get_node("terain")
@onready var main_camera = get_node("main_camera")

# Atlas tiles cords
var dirt_cell_cords: Vector2 = Vector2(1, 14)
var grass_cell_cords: Vector2 = Vector2(1, 13)
var dirt_background_cell_cords: Vector2 = Vector2(1,2)

var gnome_offset: int = 4;
var gnome_position_factor: int = 8;
var gnomes_to_move: Array = []
var gnomes_updated_positions: Array = []
var grid_data: Array = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.init_grid_data.connect(_on_init_data_recieved)
	SignalBus.update_grid_data.connect(_on_update_grid_recieved)
	SignalBus.update_dwarfs_data.connect(_on_update_dwarfs_recieved)
	Socket.init_connection()
	
	for x in 1000:
		terrain.set_cell(Vector2(x, -1), 1, grass_cell_cords)
		for y in 1000:
			terrain.set_cell(Vector2(x, y), 1, dirt_cell_cords)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_gnomes(delta)

func _on_init_data_recieved(data: Array) -> void:
	grid_data = data;
	for cell in data:
		#Set tile type on TileMapGrid
		set_dirt_tile(cell)
		if (cell["dwarf"]):
			#Generate a gnome and add to the scene
			self.add_child(generate_gnome(cell))
			
func _on_update_dwarfs_recieved(data: Dictionary) -> void:
	for dwarf in data["dwarfs"]:
		get_value_by_id(dwarf["id"], grid_data)
		gnomes_updated_positions.push_front(dwarf)

func _on_update_grid_recieved(data: Dictionary) -> void:
	for cell in data["cells"]:
		set_dirt_tile(cell)

func set_dirt_tile(cell: Dictionary) -> void:
	if (cell["digged"]):
		terrain.set_cell(Vector2(cell["x"], cell["y"]), 1, dirt_background_cell_cords)
	else:
		terrain.set_cell(Vector2(cell["x"], cell["y"]), 1, dirt_cell_cords)

func generate_gnome(cell: Dictionary) -> Node2D:
	var gnome: AnimatedSprite2D = Gnome.instantiate()
	gnome.name = str(cell["dwarf"]["id"])
	gnome.position = Vector2(
		cell["dwarf"]["x"] * gnome_position_factor + gnome_offset,
		cell["dwarf"]["y"] * gnome_position_factor + gnome_offset)
	if (cell["dwarf"]["direction"]):
		match(cell["dwarf"]["direction"]):
			"W":
				gnome.animation = "walk"
				gnome.flip_h = true
				gnome.play()
			"E":
				gnome.animation = "walk"
				gnome.play()
			_:
				gnome.animation = "idle"
	return gnome

func get_value_by_id(target_id: String, data: Array):
	for cell in data:
		if (cell["dwarf"]):
			if (cell["dwarf"]["id"] == target_id):
				gnomes_to_move.push_front(cell["dwarf"])
		

func move_gnomes(delta) -> void:
	if (gnomes_to_move.size() > 0 and gnomes_updated_positions.size() > 0):
		# Create dictionary for quick lookups of updated positions by ID
		var updated_positions_dict = {}
		for updated in gnomes_updated_positions:
			updated_positions_dict[updated["id"]] = updated
			
		# Move each gnome to its updated position
		for original in gnomes_to_move:
			var updated_dictionary_value = updated_positions_dict.get(original["id"], null)
			if updated_dictionary_value:
				var current_gnome = get_node(str(original["id"]))
				current_gnome.stop();
				current_gnome.play("walk")  # Play walk animation
				match(updated_dictionary_value["direction"]):
					"W":
						current_gnome.animation = "walk"
						current_gnome.flip_h = true
					"E":
						current_gnome.flip_h = false
					_:
						current_gnome.flip_h = false
				# Precompute target position
				var target_position = Vector2(
					updated_dictionary_value["x"] * gnome_position_factor + gnome_offset,
					updated_dictionary_value["y"] * gnome_position_factor + gnome_offset)
						
					# Create and set up tween
				var tween = create_tween()
				tween.tween_property(current_gnome, "position", target_position, 1)
				tween.tween_callback(tween_callback.bind(
					tween, current_gnome, target_position))
						
		# Clear arrays after processing
		gnomes_to_move.clear()
		gnomes_updated_positions.clear()

func tween_callback(tween: Tween, current_gnome: AnimatedSprite2D, target_position: Vector2) -> void:
	current_gnome.position = target_position  # Set final position to target
	tween.kill()  # Stop and remove tween
	current_gnome.play("idle")  # Play idle animation
