extends Button

const twitter_link = "https://google.com"
# Called when the node enters the scene tree for the first time.

func _pressed() -> void:
	OS.shell_open(twitter_link)
