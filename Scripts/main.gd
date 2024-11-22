extends Node2D

var StaticData = preload("res://Singletons/StaticData.gd")
@onready var Socket = get_node("WebsocketManager")
var Gnome = preload("res://Scenes/gnome.tscn")
@onready var terrain: TileMapLayer = get_node("terain")
@onready var main_camera: Camera2D = get_node("main_camera")

# Atlas tiles cords
var dirt_cell_cords: Vector2 = Vector2(1, 14)
var grass_cell_cords: Vector2 = Vector2(1, 13)
var dirt_background_cell_cords: Vector2 = Vector2(1,2)
var gold_cell_cords: Vector2 = Vector2(14, 4)
var rock_cell_cords: Vector2 = Vector2(14, 3)

var gnome_offset: int = 4;
var gnome_position_factor: int = 8;
var gnomes_to_move: Array = []
var gnomes_updated_positions: Array = []
var grid_data: Array = [];
var updated_positions_dict = {}

var is_init_completed = false;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.init_grid_data.connect(_on_init_data_recieved)
	SignalBus.update_dwarfs_data.connect(_on_update_dwarfs_recieved)

func _on_init_data_recieved(data: Array) -> void:
	print("init called")
	grid_data = data;
	for cell in data:
		#Set tile type on TileMapGrid
		set_dirt_tile(cell)
		if (cell.has("dwarf") && cell["dwarf"]):
			#Generate a gnome and add to the scene
			self.add_child(generate_gnome(cell))
	is_init_completed = true

func _on_update_dwarfs_recieved(data: Dictionary) -> void:
	if (!is_init_completed):
		return
	
	for dwarf in data["dwarfs"]:
		gnomes_updated_positions.push_back(dwarf)
	move_gnomes()

func set_dirt_tile(cell: Dictionary) -> void:
	match (cell["type"]):
		CellType.EMPTY:
			terrain.set_cell(Vector2(cell["x"], cell["y"]), 1, dirt_background_cell_cords)
		CellType.ROCK:
			terrain.set_cell(Vector2(cell["x"], cell["y"]), 1, dirt_background_cell_cords)
		CellType.TREASURE:
			terrain.set_cell(Vector2(cell["x"], cell["y"]), 1, gold_cell_cords)

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

func move_gnomes() -> void:
	if (gnomes_updated_positions.size() > 0):
		for updated in gnomes_updated_positions:
			updated_positions_dict[updated["id"]] = updated
			var updated_dictionary_value = updated_positions_dict.get(updated["id"], null)
			if updated_dictionary_value:
				var current_gnome = await get_node(updated["id"])
				if (current_gnome):
					current_gnome.stop();
					match(updated_dictionary_value["direction"]):
						"W":
						#current_gnome.animation = "walk"
							current_gnome.flip_h = true
						"E":
							current_gnome.flip_h = false
						_:
							current_gnome.flip_h = false
					match(updated_dictionary_value["action"]):
						GnomeActionType.DIG:
							current_gnome.animation = GnomeAnimationType.HIT
						GnomeActionType.MOVE:
							current_gnome.animation = GnomeAnimationType.WALK
						GnomeActionType.HOLD_TREASURE:
							current_gnome.animation = GnomeAnimationType.TREASURE
						_:
							current_gnome.animation = GnomeAnimationType.IDLE
					current_gnome.play()
					# Precompute target position
					var target_position = Vector2(
						updated_dictionary_value["x"] * gnome_position_factor + gnome_offset,
						updated_dictionary_value["y"] * gnome_position_factor + gnome_offset)
						
					# Create and set up tween
					var tween = create_tween()
					tween.tween_property(current_gnome, "position", target_position, 2)
					tween.tween_callback(tween_callback.bind(
						tween, current_gnome, target_position))
		# Clear arrays after processing
		gnomes_to_move.clear()
		gnomes_updated_positions.clear()
		updated_positions_dict.clear()

func tween_callback(tween: Tween, current_gnome: AnimatedSprite2D, target_position: Vector2) -> void:
	current_gnome.position = target_position  # Set final position to target
	tween.kill()  # Stop and remove tween
