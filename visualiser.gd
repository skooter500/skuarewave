extends Node3D

@export var num_bars: int = 64
@export var bar_width: float = 0.1
@export var bar_spacing: float = 0.15
@export var max_height: float = 5.0
@export var smoothing: float = 0.2
@export var scale_factor: float = 50.0
@export var min_height: float = 0.001

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
	
	# Initialize multimesh - single instance per column
	mm.multimesh.instance_count = num_bars
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var box_mesh = BoxMesh.new()
	material.vertex_color_use_as_albedo = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	box_mesh.material = material
	mm.multimesh.mesh = box_mesh
	
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
		var rainbow_color = Color.from_hsv(hue, 1, 1, 0.7)
		
		# Single bar centered at y=0, extends both up and down
		var t = Transform3D()
		t = t.scaled(Vector3(bar_width, min_height, bar_width))
		t.origin = Vector3(start_x + (i * bar_spacing), 0, 0)
		mm.multimesh.set_instance_transform(i, t)
		mm.multimesh.set_instance_color(i, rainbow_color)

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
		height = max(height, min_height)
		
		target_heights[i] = height
		
		# Smooth interpolation
		bar_heights[i] = lerp(bar_heights[i], target_heights[i], smoothing)
		
		var total_width = num_bars * bar_spacing
		var start_x = -total_width / 2.0
		var x_pos = start_x + (i * bar_spacing)
		
		# Rainbow color
		var hue = float(i) / float(num_bars)
		var rainbow_color = Color.from_hsv(hue, 1, 1, 0.4)
		
		# Single bar centered at y=0, extends both up and down
		var t = Transform3D()
		t = t.scaled(Vector3(bar_width, bar_heights[i], bar_width))
		t.origin = Vector3(x_pos, 0, 0)  # Centered at 0
		mm.multimesh.set_instance_transform(i, t)
		mm.multimesh.set_instance_color(i, rainbow_color)
