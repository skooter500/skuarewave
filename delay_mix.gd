extends Marker3D

@export var bus_index:int = 0
@export var effect_index:int = 1
var effect:AudioEffect

func _ready() -> void:
	effect = AudioServer.get_bus_effect(bus_index, effect_index)
	effect.tap1_active = true
	effect.tap1_delay_ms = 250.0  # Quarter note at 120 BPM
	effect.tap1_level_db = -6
	effect.feedback_active = true
	effect.feedback_delay_ms = 250.0
	effect.feedback_level_db = -6  # Crank for dub-style repeats


func _process(delta: float) -> void:
	effect.dry = 1.0 - $grab.value
