extends ItemList

@onready var search_input: LineEdit = get_node("../leaderboard_search")
@onready var main_camera: Camera2D = get_node("../../../../main_camera")
var leaderboard_data = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.fetch_leaderboard_data.connect(_handle_leaderbpard_data)
	self.item_selected.connect(_handle_item_selected)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_filter_input()
	

func _handle_item_selected(id: int):
	var gnome_id = self.get_item_text(id)
	var gnome: AnimatedSprite2D = await get_node("../../../../" + gnome_id)
	if (gnome):
		main_camera.position_smoothing_enabled = true
		main_camera.zoom = Vector2(13,13);
		var offset = Vector2(-45, -25)
		main_camera.position = gnome.position + offset
		var tween = create_tween()
		var oldModulate = gnome.modulate;
		for n in 3:
			tween.tween_property(gnome, "modulate", Color.ROYAL_BLUE, 0.5).set_trans(Tween.TRANS_SINE)
			tween.tween_property(gnome, "modulate", oldModulate, 0.5).set_trans(Tween.TRANS_SINE)


func _handle_filter_input():
	if (leaderboard_data.size() > 0):
		self.clear()
		self.add_item("Gnome ID", null, false)
		self.add_item("Score", null, false)
		var filtered_data = leaderboard_data
		if (search_input.text):
			filtered_data = filtered_data.filter(func(element): return element["id"].contains(search_input.text))
		for item in filtered_data:
			self.add_item(item["id"])
			self.add_item(str(item["score"]),null, false)

func _handle_leaderbpard_data(data: Dictionary):
	leaderboard_data = data["leaderBoard"]
