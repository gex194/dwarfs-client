extends Button

var StaticData = preload("res://Singletons/StaticData.gd")

func _pressed() -> void:
	StaticData.load_json_file("res://Data/update_game_data.json", true)
