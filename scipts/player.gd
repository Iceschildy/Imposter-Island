extends CharacterBody3D

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

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.current = is_multiplayer_authority()


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

		if Input.is_action_pressed("Sprint"):
			speed = sprint_speed
		else:
			speed = WALK_SPEED
		
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
			else:
				velocity.x = 0.0
				velocity.z = 0.0
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		
		var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
		var target_fov = Base_Fov + Fov_Change * velocity_clamped
		cam.fov = lerp(cam.fov, target_fov, delta * 8.0)
		rotate_player_model()
		move_and_slide()


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
		print("+1 Wood")
	else:
		print("Wood not found")

func _on_area_3d_body_entered(body):
	
	#when player is touching wood; call the rpc function
	if body.is_in_group("wood"):
		var wood_path = body.get_path()
		var position = body.global_transform.origin
		rpc("collect_item", wood_path, position)
func rotate_player_model():
	charater_model.rotation.y = head.rotation.y 
