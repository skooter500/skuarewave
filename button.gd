extends Area3D

var in_color:Color
var out_color:Color

func _ready() -> void:
	in_color = Color.from_hsv(randf(), 1, 1, 0.5)
	out_color = Color.from_hsv(fmod(in_color.h + 0.5, 1.0), 1, 1, 0.5)
	var mat = $MeshInstance3D.get_surface_override_material(0)
	mat = mat.duplicate()
	mat.albedo_color = out_color
	$MeshInstance3D.set_surface_override_material(0, mat)	

func _on_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	$MeshInstance3D.get_surface_override_material(0).albedo_color = in_color 
	pass # Replace with function body.


func _on_area_exited(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	$MeshInstance3D.get_surface_override_material(0).albedo_color = out_color	
	pass # Replace with function body.
