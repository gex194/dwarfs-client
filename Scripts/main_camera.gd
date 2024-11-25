extends Camera2D

@export var zoom_speed: float = 3
@export var max_zoom: Vector2 = Vector2(10, 10)
@export var tilemaplayer: TileMapLayer

@onready var gui_control: ItemList = get_node("../GUI_Layer/GUI/leaderboard_panel/leaderboard_list")

var previous_position: Vector2 = Vector2(0,0)
var move_camera: bool = false;
var max_zoomout = Vector2(0.16345, 0.16345)
var sky_offset_y = 499

var is_map_scroll_enabled = true;

func _ready() -> void:
	gui_control.mouse_entered.connect(disable_map_scroll)
	gui_control.mouse_exited.connect(enable_map_scroll)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handleCameraControls(delta)
	clamp_camera_with_zoom(self)

func on_grid_rendered():
	self.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	var zoom_vector = get_camera_zoom_to_tilemap()
	self.zoom = zoom_vector
	max_zoomout = zoom_vector
	apply_camera_limits()

func apply_camera_limits() -> void:
	var viewport_size = self.get_viewport().size
	var tilemap_info = get_tilemap_info()
	var level_size = Vector2i(tilemap_info.tile_size * tilemap_info.size)
	
	self.set_limit(SIDE_TOP, -500)
	self.set_limit(SIDE_LEFT, 0)
	self.set_limit(SIDE_RIGHT, level_size.x)
	self.set_limit(SIDE_BOTTOM, level_size.y)

func get_camera_zoom_to_tilemap() -> Vector2:
	var viewport_size = get_viewport().size
	var tilemap_info = get_tilemap_info()
	var level_size = Vector2i(tilemap_info.tile_size * tilemap_info.size)
	
	var viewpor_aspect: float = viewport_size.x * 1.0 / viewport_size.y * 1.0
	var level_aspect: float = level_size.x * 1.0 / level_size.y * 1.0
	
	var new_zoom: float = 1.0
	
	if (level_aspect > viewpor_aspect):
		new_zoom = viewport_size.y * 1.0 / level_size.y * 1.0
	else:
		new_zoom = viewport_size.x * 1.0 / level_size.x * 1.0
	return Vector2(new_zoom, new_zoom)

func clamp_camera_with_zoom(camera: Camera2D):
	# Get the camera's viewport size and zoom level
	var viewport_size = camera.get_viewport_rect().size
	var half_visible_size = (viewport_size / 2) * camera.zoom

	# Calculate the limits for the camera's position
	var min_x = camera.limit_left
	var max_x = camera.limit_right - (viewport_size.x / camera.zoom.x)
	var min_y = camera.limit_top
	var max_y = camera.limit_bottom + sky_offset_y - viewport_size.y / camera.zoom.y

	# Clamp the camera's position to stay within bounds
	var clamped_position = camera.position
	clamped_position.x = clamp(clamped_position.x, min_x, max_x)
	clamped_position.y = clamp(clamped_position.y, min_y, max_y)
	camera.position = clamped_position

func get_tilemap_info():
	var tile_size = tilemaplayer.tile_set.tile_size
	var tilemap_rect = tilemaplayer.get_used_rect()
	print(tilemap_rect.position.y)
	var tilemaplayer_size = Vector2i(
		tilemap_rect.end.x - tilemap_rect.position.x,
		tilemap_rect.end.y - abs(tilemap_rect.position.y) + sky_offset_y
	)
	
	return {"size": tilemaplayer_size, "tile_size": tile_size}

func enable_map_scroll() -> void:
	is_map_scroll_enabled = true

func disable_map_scroll() -> void:
	is_map_scroll_enabled =  false

func handleCameraControls(delta) -> void:
	if (is_map_scroll_enabled):
		if (Input.is_action_just_released("ZoomIn") && self.zoom < max_zoom):
			self.position_smoothing_enabled = false
			var mouse_pos = get_global_mouse_position()
			self.zoom = lerp(self.zoom, self.zoom + Vector2(zoom_speed, zoom_speed), zoom_speed * self.zoom.x * delta)
			var new_mouse_pos = get_global_mouse_position()
			self.position += mouse_pos - new_mouse_pos
		if (Input.is_action_just_released("ZoomOut") && self.zoom > max_zoomout):
			self.zoom = lerp(self.zoom, self.zoom - Vector2(zoom_speed, zoom_speed), zoom_speed * self.zoom.x * delta)
			if (self.zoom < max_zoomout):
				self.zoom = max_zoomout


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		self.position_smoothing_enabled = true
		get_viewport().set_input_as_handled();
		if event.is_pressed():
			previous_position = event.position;
			move_camera = true;
		else:
			move_camera = false;
	elif event is InputEventMouseMotion && move_camera:
		get_viewport().set_input_as_handled();
		self.position += (previous_position - event.position) / self.zoom;
		previous_position = event.position;
