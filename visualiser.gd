extends Node3D

@export var num_bars: int = 64
@export var bar_width: float = 0.1
@export var bar_spacing: float = 0.15
@export var max_height: float = 5.0
@export var smoothing: float = 0.2
@export var scale_factor: float = 50.0
@export var min_height: float = 0.001  # Much smaller minimum

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var mm: MultiMeshInstance3D = $MultiMeshInstance3D

var spectrum: AudioEffectSpectrumAnalyzerInstance
var bar_heights: Array = []
var target_heights: Array = []

func _ready():
	# Get spectrum analyzer
	var idx = AudioServer.get_bus_index("Master")
	var effect = AudioServer.get_bus_effect(idx, 0)
	if effect is AudioEffectSpectrumAnalyzer:
		spectrum = AudioServer.get_bus_effect_instance(idx, 0)
	else:
		# Add spectrum analyzer if not present
		var spectrum_effect = AudioEffectSpectrumAnalyzer.new()
		AudioServer.add_bus_effect(idx, spectrum_effect)
		spectrum = AudioServer.get_bus_effect_instance(idx, 0)
	
	# Initialize multimesh - double the bars for mirroring
	mm.multimesh = MultiMesh.new()
	mm.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mm.multimesh.instance_count = num_bars * 2  # Top and bottom
	mm.multimesh.mesh = BoxMesh.new()
	
	# Initialize height arrays with minimum height
	for i in range(num_bars):
		bar_heights.append(min_height)
		target_heights.append(min_height)
	
	create_bars()

func create_bars():
	var total_width = num_bars * bar_spacing
	var start_x = -total_width / 2.0
	
	for i in range(num_bars):
		# Rainbow colors - map index to hue
		var hue = float(i) / float(num_bars)
		var rainbow_color = Color.from_hsv(hue, 1, 1, 0.5)
		
		# Top bar
		var t_top = Transform3D()
		t_top = t_top.scaled(Vector3(bar_width, min_height, bar_width))
		t_top.origin = Vector3(start_x + (i * bar_spacing), min_height / 2.0, 0)
		mm.multimesh.set_instance_transform(i, t_top)
		mm.multimesh.set_instance_color(i, rainbow_color)
		
		# Bottom bar (mirrored)
		var t_bottom = Transform3D()
		t_bottom = t_bottom.scaled(Vector3(bar_width, min_height, bar_width))
		t_bottom.origin = Vector3(start_x + (i * bar_spacing), -min_height / 2.0, 0)
		mm.multimesh.set_instance_transform(i + num_bars, t_bottom)
		mm.multimesh.set_instance_color(i + num_bars, rainbow_color)

func _process(delta: float) -> void:
	if not spectrum:
		return
	
	# Get spectrum data
	var freq_min = 20.0
	var freq_max = 20000.0
	
	for i in range(num_bars):
		# Map bar index to frequency range (logarithmic)
		var freq = freq_min * pow(freq_max / freq_min, float(i) / num_bars)
		var magnitude = spectrum.get_magnitude_for_frequency_range(freq, freq * 1.1).length()
		
		# Scale to max_height
		var height = magnitude * scale_factor
		if height > max_height:
			height = max_height
		height = max(height, min_height)  # Use configurable minimum
		
		target_heights[i] = height
		
		# Smooth interpolation
		bar_heights[i] = lerp(bar_heights[i], target_heights[i], smoothing)
		
		var total_width = num_bars * bar_spacing
		var start_x = -total_width / 2.0
		var x_pos = start_x + (i * bar_spacing)
		
		# Rainbow color
		var hue = float(i) / float(num_bars)
		var rainbow_color = Color.from_hsv(hue, 1, 1, 0.7)
		
		# Top bar (grows upward)
		var t_top = Transform3D()
		t_top = t_top.scaled(Vector3(bar_width, bar_heights[i], bar_width))
		t_top.origin = Vector3(x_pos, bar_heights[i] / 2.0, 0)
		mm.multimesh.set_instance_transform(i, t_top)
		mm.multimesh.set_instance_color(i, rainbow_color)
		
		# Bottom bar (grows downward - mirrored)
		var t_bottom = Transform3D()
		t_bottom = t_bottom.scaled(Vector3(bar_width, bar_heights[i], bar_width))
		t_bottom.origin = Vector3(x_pos, -bar_heights[i] / 2.0, 0)
		mm.multimesh.set_instance_transform(i + num_bars, t_bottom)
		mm.multimesh.set_instance_color(i + num_bars, rainbow_color)
