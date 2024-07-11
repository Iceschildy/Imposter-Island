extends CharacterBody3D

var healt_losing_rate = 1
var health : float = 100
var speed 
const WALK_SPEED = 4.0
const sprint_speed = 8.0
const JUMP_VELOCITY = 4.5
const sensitivity = 0.002

const Base_Fov = 75.0
const Fov_Change = 1.5

var gravity = 9.8

@onready var head = $Head
@onready var cam = $Head/Camera3D
@onready var interactable_ray = $Head/RayCast3D
@onready var charater_model = $CollisionShape3D/CharaterModel
@export var wood_scene : PackedScene
@onready var ui_ingame = $"../UI Ingame"
@onready var health_bar = $"../UI Ingame/Healthbar"
@onready var character_mesh = $CollisionShape3D/CharaterModel/RootNode/Skeleton3D/SM_Chr_Santa_01


func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.current = is_multiplayer_authority()
	var ui_ingame = get_node("UI Ingame")
	if is_multiplayer_authority():
		character_mesh.transparency = 1
	Global.set_player_reference(self)
	
func _unhandled_input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * sensitivity)
			cam.rotate_x(-event.relative.y * sensitivity)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(60))
		
func _physics_process(delta):
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		# Handle jump.
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if Input.is_action_pressed("Sprint") and ui_ingame.can_sprint:
			speed = sprint_speed
		else:
			speed = WALK_SPEED
			
			
		
		if Input.is_action_just_pressed("Inventory"):
			open_inventory()
		# Quit the game when ctrl and esc are pressed
		if Input.is_action_just_pressed("quit"):
			$"../".exit_game(name.to_int())
			get_tree().quit()
		
		if Input.is_action_just_pressed("destroy"):
			if interactable_ray.is_colliding():
				var collision = interactable_ray.get_collider()
				if collision.is_in_group("Palm"):
					var path = collision.get_path()
					var position = collision.global_transform.origin
					rpc("destroy_tree", path, position)

		var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
				ui_ingame.is_moving = true
			else:
				velocity.x = 0.0
				velocity.z = 0.0
				ui_ingame.is_moving = false
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		
		var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
		var target_fov = Base_Fov + Fov_Change * velocity_clamped
		cam.fov = lerp(cam.fov, target_fov, delta * 8.0)
		rotate_player_model()
		move_and_slide()
		
func _process(delta):
	if ui_ingame.saturation <= 0 or ui_ingame.thirst <= 0:
		lose_damage_by_hunger_thirst(delta)
		
	health_bar.value = health

@rpc("any_peer", "call_local", "reliable")
func destroy_tree(tree_path, position):
	var tree = get_node(tree_path)
	if tree and tree.is_in_group("Palm"):
		var wood_inst = wood_scene.instantiate()
		add_sibling(wood_inst)
		wood_inst.add_to_group("wood")
		wood_inst.position = position + Vector3(0, 1, 0)
		tree.queue_free()
				
@rpc("any_peer", "call_local", "reliable")
func collect_item(item_path, position):
	var item = get_node(item_path)
	if item:
		item.queue_free()

func _on_area_3d_body_entered(body):
	
	#when player is touching wood; call the rpc function
	if body.is_in_group("wood"):
		var wood_path = body.get_path()
		var position = body.global_transform.origin
		rpc("collect_item", wood_path, position)
	if body.is_in_group("stick"):
		var stick_path = body.get_path()
		var position = body.global_transform.origin
		rpc("collect_item", stick_path, position)
		
		
func rotate_player_model():
	charater_model.rotation_degrees.y = head.rotation_degrees.y 
	print("Characthermodel: " + str(charater_model.rotation.y))
	print("Head rotation" + str(head.rotation.y))
func lose_damage_by_hunger_thirst(delta):
	
	if health > 0:
		health -= healt_losing_rate * delta
	if health > 100:
		health = 100

func die():
	#Nur platzhalter. Funktion zum sterben muss noch hinzugefügt werden
	print("Player Died" )
	
func open_inventory():
	pass
