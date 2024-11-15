extends Camera2D

@export var zoom_speed: int = 5
@export var max_zoom: Vector2 = Vector2(10, 10)

var previous_position: Vector2 = Vector2(0,0)
var move_camera: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handleCameraControls(delta)

func handleCameraControls(delta) -> void:
	if (Input.is_action_just_released("ZoomIn") && self.zoom < max_zoom):
		self.zoom = lerp(self.zoom, self.zoom + Vector2(zoom_speed, zoom_speed), zoom_speed * delta)
	if (Input.is_action_just_released("ZoomOut") && self.zoom > Vector2.ONE):
		self.zoom = lerp(self.zoom, self.zoom - Vector2(zoom_speed, zoom_speed), zoom_speed * delta)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
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
