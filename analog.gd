extends Area3D

var hand
var d:float = 0
var start_y:float
var end_y:float
@export var value:float = 0
var height = 0.5
@export var min:float = 0
@export var max:float = 1

@export var whole:bool = false 

@export var rod:PackedScene

signal value_changed

func _ready() -> void:
	var c = Color.from_hsv(randf(), 1, 1, 0.5)

	var mat = $mesh.get_surface_override_material(0)
	mat = mat.duplicate()
	mat.albedo_color = c
	$mesh.set_surface_override_material(0, mat)
	$"../rod".set_surface_override_material(0, mat)
	start_y = global_position.y
	end_y = global_position.y + height
	
	var y = remap(value, min, max, start_y, end_y)
	global_position.y = y
	create_rod()
	
func create_rod():
	var y = start_y + (height / 2.0)
	$"../rod".global_position.y = y
	$"../rod".scale.y = height
	pass

func set_value(value):
	self.value = value
	var y = remap(value, min, max, start_y, end_y)
	global_position.y = y
	  

func _on_grab_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	hand = area.get_parent().get_parent().get_parent().get_parent().get_parent()
	d = global_position.y - hand.global_position.y
	pass # Replace with function body.


func _on_grab_area_exited(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	hand = null	
	pass # Replace with function body.

func _process(delta: float) -> void:
	if hand:
		var new_y = hand.global_position.y + d
		global_position.y = clamp(new_y, start_y, end_y)
		
		# hand_start_y = hand.position.y		
	value = remap(global_position.y, start_y, end_y, min, max)
	
	if whole:
		$"label".text = str(int(round(value)))
	else:
		$"label".text = "%.2f" % value
