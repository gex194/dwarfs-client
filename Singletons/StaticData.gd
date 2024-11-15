extends Node

static func load_json_file(filePath = "res://Data/game_data.json", update = false):
	if (FileAccess.file_exists(filePath)):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			if (update):
				print(parsedResult)
				SignalBus.update_grid_data.emit(parsedResult)
			else:
				SignalBus.init_grid_data.emit(parsedResult)
		else:
			print("Error reading file")
	else:
		print("File doesnt exists")
