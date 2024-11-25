extends Label

@onready var timer: Timer = $"../../../../Timer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = "%02d:%02d" % time_left_to_play()

func time_left_to_play() -> Array:
	var time_left = timer.time_left
	var minutes = floor(time_left /60)
	var seconds = int(time_left) % 60
	return [minutes, seconds]
