extends Marker3D

@export var bus_index:int = 0 

func set_volume_0_to_10(value: float):
	value = clamp(value, 0.0, 10.0)
	
	if value == 0:
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		# Exponential curve feels more natural
		var normalized = pow(value / 10.0, 2.0)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(normalized))

func _ready():
	pass

func  _process(delta: float) -> void:
	set_volume_0_to_10($grab.value)
	pass
