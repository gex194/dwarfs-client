extends Node

@export var websocket_url = "ws://127.0.0.1:8000"
var socket = WebSocketPeer.new()

func _ready() -> void:
	init_connection()

func _process(delta: float) -> void:
	socket.poll()
	
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var parsedResult = JSON.parse_string(socket.get_packet().get_string_from_utf8())
			var data = parsedResult["data"]
			match(parsedResult["type"]):
				"fullGrid":
					SignalBus.init_grid_data.emit(data)
				"updateCells":
					SignalBus.update_grid_data.emit(data)
				"updateDwarfs":
					SignalBus.update_dwarfs_data.emit(data)
				"updateLeaderBoard":
					SignalBus.fetch_leaderboard_data.emit(data)
				"gamePaused":
					SignalBus.pause_game.emit(data)
				"addDwarfs":
					SignalBus.add_dwarfs_data.emit(data)
	
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.

func _exit_tree() -> void:
	socket.close()

func init_connection() -> void:
	socket.inbound_buffer_size = 65535 * 100
	var err = socket.connect_to_url(websocket_url)
	if (err != OK):
		print("Unable to connect")
		set_process(false)
