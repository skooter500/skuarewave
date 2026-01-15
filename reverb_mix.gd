extends Marker3D

@export var bus_index:int = 0
@export var effect_index:int = 0

var effect:AudioEffect

func _ready() -> void:
	effect = AudioServer.get_bus_effect(bus_index, effect_index)
	
func _process(delta: float) -> void:
	if "wet" in effect:
		effect.wet = $grab.value
	effect.dry = 1.0 - $grab.value
