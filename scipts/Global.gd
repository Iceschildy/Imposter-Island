extends Node

var inventory = []

var player_node : Node = null
signal  inventory_updated
func _ready():
	inventory.resize(27)
	
func add_item():
	inventory_updated.emit()
	
func remove_item():
	inventory_updated.emit()
	
func ser_player_reference(player):
	player_node = player
