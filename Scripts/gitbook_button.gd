extends Button


const gitbook_link = "https://innfinite.gitbook.io/mines"
# Called when the node enters the scene tree for the first time.

func _pressed() -> void:
	OS.shell_open(gitbook_link)
