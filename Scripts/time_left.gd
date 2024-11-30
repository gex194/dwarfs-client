extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.init_grid_data.connect(_on_init_grid_data_recieved)
	SignalBus.pause_game.connect(_on_game_pause_recieved)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_game_pause_recieved(data: Dictionary) -> void:
	self.text = "Starts in:"

func _on_init_grid_data_recieved(data: Array) -> void:
	self.text = "Time left:"
