extends XRCamera3D

var distance_in_front = -2


@export var spawn_in_front:Node3D 
@export var boid:Node3D 

func _ready() -> void:
	await get_tree().process_frame
	var y = spawn_in_front.global_position.y
	print("Head pos" + str(global_position))
	var in_front = global_position + (global_basis.z * distance_in_front)
	in_front.y = y
	
	
	spawn_in_front.global_position = in_front
	# boid.global_position = in_front
	var y_rotation = global_basis.get_euler().y
	spawn_in_front.global_basis = Basis(Vector3.UP, y_rotation).scaled(spawn_in_front.scale)
	
