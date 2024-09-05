extends StaticBody3D


var gravity_items := 9.8

@onready var ray_cast_3d = $RayCast3D


func _physics_process(delta):
	if ray_cast_3d.is_colliding():
		pass
	else:
		position.y -= gravity_items * delta

