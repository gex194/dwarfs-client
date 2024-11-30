extends Label

var gnomes: Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.fetch_leaderboard_data.connect(_handle_leaderbpard_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _handle_leaderbpard_data(data: Dictionary) -> void:
	self.text = str(data["leaderBoard"].size())
