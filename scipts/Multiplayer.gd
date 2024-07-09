extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var ip = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Ip
@onready var ui_ingame = $"UI Ingame"

const player = preload("res://scenes/Player.tscn")
const PORT = 2096
var enet_peer = ENetMultiplayerPeer.new()
# Called to host the game

# Called to join the game



# Handle successful connection to server
func _on_connected():
	print("Successfully connected to server")

# Handle connection failure
func _on_connection_failed():
	print("Failed to connect to server")

# Handle server disconnection
func _on_disconnected():
	print("Disconnected from server")

# Handle game exit (called in player function)
func exit_game(id):
	multiplayer.peer_disconnected.connect(remove_player)
	remove_player(id)


func _on_host_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	ui_ingame.show()
func _on_join_pressed():
	main_menu.hide()
	
	enet_peer.create_client(ip.text, PORT)
	print(ip.text)
	multiplayer.multiplayer_peer = enet_peer
	ui_ingame.show()
func add_player(peer_id):
	var player = player.instantiate()
	player.name = str(peer_id)
	add_child(player)
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


