extends Node2D

var saturation = 100
@onready var progress_bar = $ProgressBar
var sprinting = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#Man sieht die Ui am Anfang im Host oder Join Bildschirm und sie wird dort auch abgespielt - Noch nicht gefixed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("Sprint"):
		sprinting = true
	else:
		sprinting = false
	
	
	if saturation >= 0 and sprinting:
		saturation -= 1 * delta
		
		
	
	
	if saturation >= 0:
		saturation -= 0.1 * delta
		
		
	
	progress_bar.value = saturation
	print(saturation)
	
	
