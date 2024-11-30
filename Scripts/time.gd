extends Label

@onready var timer: Timer = $"../../../../Timer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.pause_game.connect(_on_game_pause_recieved)
	SignalBus.game_ends_time.connect(_on_end_time_recieved)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = "%02d:%02d" % time_left_to_play()
	

func _on_end_time_recieved(data: Dictionary) -> void:
	var time: int = data["gameEndsIn"]
	timer.stop()
	timer.wait_time = time / 1000
	timer.start()

func _on_game_pause_recieved(data: Dictionary) -> void:
	timer.stop()
	timer.wait_time = data["gameStartsIn"] / 1000
	timer.start()

func time_left_to_play() -> Array:
	var time_left = timer.time_left
	var minutes = floor(time_left /60)
	var seconds = int(time_left) % 60
	return [minutes, seconds]
