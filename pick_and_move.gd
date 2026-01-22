extends Area3D
var hand:Node3D = null
var held:Node3D = null
var old_parent:Node3D = null

func _on_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	hand = area.get_parent().get_parent().get_parent().get_parent().get_parent()
	print(hand)

func _on_area_exited(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	
	hand = null
	
	if held:
		print("Removing")
		held.reparent(old_parent, true)
		hand = null
		held = null
	pass

func _process(delta: float) -> void:
	if hand:
		print(hand.gesture)
		if hand.gesture == "Fist":
			if not held:
				print("Adding")
				held = get_parent()
				old_parent = held.get_parent()
				held.reparent(hand, true)
		else:
			if held:
				print("Removing")
				held.reparent(old_parent, true)		
				held = null	
				hand = null
