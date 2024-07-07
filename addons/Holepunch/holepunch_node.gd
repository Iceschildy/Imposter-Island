extends Node

signal  hole_punched

var rendevouz_address = "your-service-name.onrender.com"
var rendevouz_port = 7777
var udp_socket : UDPServer

func _ready():
	udp_socket = UDPServer.new()
	udp_socket.listen(0)

func start_traversal(game_code: String, is_host: bool, player_id: String):
	if is_host:
		var message = "REGISTER_SESSION:%s:%d" % [game_code, 2]
		udp_socket.put_packet(message.to_utf8())
	else:
		var message = "REGISTER_CLIENT:%s:%s" % [player_id, game_code]
		udp_socket.put_packet(message.to_utf8())
	await get_tree().create_timer(0.1).timeout
