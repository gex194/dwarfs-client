extends Button

func _pressed() -> void:
	$"../leaderboard_panel".visible = !$"../leaderboard_panel".visible
