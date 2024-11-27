extends Node

func set_dirt_tile(cell: Dictionary, terrain: TileMapLayer) -> void:
	var cell_cords = Vector2(cell["x"], cell["y"])
	match (cell["type"]):
		CellType.EMPTY:
			terrain.set_cell(cell_cords, 1, CellTypeCords.EMPTY)
		CellType.ROCK:
			terrain.set_cell(cell_cords, 1, CellTypeCords.ROCK)
		CellType.GOLD:
			terrain.set_cell(cell_cords, 1, CellTypeCords.GOLD)
		CellType.IRON:
			terrain.set_cell(cell_cords, 1, CellTypeCords.IRON)
		CellType.RUBY:
			terrain.set_cell(cell_cords, 1, CellTypeCords.RUBY)
		CellType.SAPPHIRE:
			terrain.set_cell(cell_cords, 1, CellTypeCords.SAPPHIRE)
		CellType.DIAMOND:
			terrain.set_cell(cell_cords, 1, CellTypeCords.DIAMOND)
