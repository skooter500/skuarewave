extends Node3D

var effect: AudioEffect

var stereo: bool = true
var mix_rate := 44100  # This is the default mix rate on recordings.
var format := AudioStreamWAV.FORMAT_16_BITS  # This is the default format on recordings.


func _ready() -> void:
	var idx := AudioServer.get_bus_index(&"Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	effect.set_recording_active(true)
