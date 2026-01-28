extends Node3D

func _ready() -> void:
	sequencers.push_back($drums/pickable/sequencer)
	sequencers.push_back($sequencer/pickable/sequencer)
	sequencers.push_back($sequencer2/pickable/sequencer)
	sequencers.push_back($sequencer3/pickable/sequencer)
	sequencers.push_back($sequencer4/pickable/sequencer)

	

func _on_start_stop_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	if $Timer.is_stopped():
		$"Timer".start()
		$pickable/controls/mode2.text = "stop"
	else:
		$"Timer".stop()
		$pickable/controls/mode2.text = "Start"
	pass # Replace with function body.

var sequencers = []

func _on_timer_timeout() -> void:
	for sequencer in sequencers:
		sequencer.next_step()
	pass # Replace with function body.


func _on_reverb_area_entered(_area: Area3D) -> void:
	if not _has_effect(0, AudioEffectReverb):
		var reverb = AudioEffectReverb.new()
		AudioServer.add_bus_effect(0, reverb)
	else:
		_remove_effect(0, AudioEffectReverb)

func _on_delay_area_entered(_area: Area3D) -> void:
	if not _has_effect(0, AudioEffectDelay):
		var delay = AudioEffectDelay.new()
		delay.tap1_active = true
		delay.tap1_delay_ms = 250.0  # Quarter note at 120 BPM
		delay.tap1_level_db = -6
		delay.feedback_active = true
		delay.feedback_delay_ms = 250.0
		delay.feedback_level_db = -6  # Crank for dub-style repeats
		AudioServer.add_bus_effect(0, delay)
	else:
		_remove_effect(0, AudioEffectDelay)

# Helper function to check if a specific effect type exists on a bus
func _has_effect(bus_idx: int, effect_class) -> bool:
	for i in range(AudioServer.get_bus_effect_count(bus_idx)):
		if is_instance_of(AudioServer.get_bus_effect(bus_idx, i), effect_class):
			return true
	return false

# Helper function to find and remove a specific effect type
func _remove_effect(bus_idx: int, effect_class) -> void:
	for i in range(AudioServer.get_bus_effect_count(bus_idx)):
		if is_instance_of(AudioServer.get_bus_effect(bus_idx, i), effect_class):
			AudioServer.remove_bus_effect(bus_idx, i)
			break # Stop after removing one instance


func _on_mic_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
