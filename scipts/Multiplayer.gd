extends Node

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
@export var server_port = 1027

# Called to host the game
	

# Called to join the game
func _ready():
	var ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	$CanvasLayer/MyIp.text = str(ip)
	
# Handle player connection
func _on_player_connected(id):
	print("Player %d connected" % id)
	add_player(id)

# Handle player disconnection
func _on_player_disconnected(id):
	print("Player %d disconnected" % id)
	remove_player(id)

# Add player to the game
func add_player(id):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

# Remove player from the game
func remove_player(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()

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
	var result = peer.create_server(server_port)
	if result == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		_on_player_connected(1)  # Host player is always peer ID 1
		print("Server started on port %s" % server_port)
	else:
		print("Failed to create server: %s" % result)
		
	


func _on_join_pressed():
	var ip_address = $CanvasLayer/Ip.get_text()
	var result = peer.create_client(ip_address, server_port)
	if result == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(_on_connected)
		multiplayer.connection_failed.connect(_on_connection_failed)
		multiplayer.server_disconnected.connect(_on_disconnected)
		print("Connected to server at %s" % ip_address)
		
	else:
		print("Failed to connect to server: %s" % result)
	
