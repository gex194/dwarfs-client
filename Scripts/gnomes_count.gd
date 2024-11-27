extends Label

var gnomes: Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.init_grid_data.connect(_on_init_data_recieved)
	SignalBus.add_dwarfs_data.connect(_on_add_dwarfs_data)
	SignalBus.pause_game.connect(_on_game_pause_recieved)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_add_dwarfs_data(data: Dictionary) -> void:
	for dwarf in data["dwarfs"]:
		gnomes.append(dwarf)
	self.text = str(gnomes.size())

func _on_game_pause_recieved(data: Dictionary) -> void:
	gnomes.clear();
	self.text = "0";

func _on_init_data_recieved(data: Array) -> void:
	for cell in data:
		if (cell.has("dwarf") && cell["dwarf"]):
			#Generate a gnome and add to the scene
			gnomes.append(cell)
	self.text = str(gnomes.size())
