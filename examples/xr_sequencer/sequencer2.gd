extends Marker3D

@export var font:Font 

var sequence = []
var file_names = []

@export var pad_scene:PackedScene

@export var steps:int = 8
@export var notes:int = 16


signal start
signal step
signal stop

@export var out_color:Color
@export var in_color:Color
@export var hit_color:Color

enum Step {OFF, ON, HIT_ON, HIT_OFF}


@export var instrument:int = 1
@export var midi_channel:int = 1
@export var root_note:int = 68

@onready var midi_player:MidiPlayer = $"../MidiPlayer"

func change_instrument(channel: int, program: int):
	var midi_event = InputEventMIDI.new()
	midi_event.channel = channel
	midi_event.message = MIDI_MESSAGE_PROGRAM_CHANGE
	midi_event.instrument = program
	midi_player.receive_raw_midi_message(midi_event)

func _ready():
	# load_samples()
	initialise_sequence(notes, steps)
	
	make_sequencer()
	
	in_color = Color.from_hsv(randf(), 1, 1, 0.5)
	out_color = Color.from_hsv(fmod(in_color.h + 0.3, 1.0), 1, 1, 0.5)
	hit_color = Color.from_hsv(fmod(out_color.h + 0.3, 1.0), 1, 1, 0.5)
	
	assign_colors()
	midi_notes = get_scale_notes(root_note, mucical_scale)
	
	change_instrument(midi_channel, instrument)
	
	


enum Scale {
	MAJOR,
	MINOR,
	HARMONIC_MINOR,
	MELODIC_MINOR,
	DORIAN,
	PHRYGIAN,
	LYDIAN,
	MIXOLYDIAN,
	LOCRIAN,
	PENTATONIC_MAJOR,
	PENTATONIC_MINOR,
	BLUES,
	BLUES_MAJOR,
	BEBOP_DOMINANT,
	BEBOP_MAJOR,
	WHOLE_TONE,
	CHROMATIC,
	JAPANESE,  # Hirajoshi
	EGYPTIAN,
	HUNGARIAN_MINOR,
	IRISH,  # Hexatonic - common in trad
}

var mucical_scale:Scale = Scale.MAJOR

# Define scale intervals (semitones from root)
var scale_intervals = {
	Scale.MAJOR: [0, 2, 4, 5, 7, 9, 11],
	Scale.MINOR: [0, 2, 3, 5, 7, 8, 10],  # Natural minor
	Scale.HARMONIC_MINOR: [0, 2, 3, 5, 7, 8, 11],
	Scale.MELODIC_MINOR: [0, 2, 3, 5, 7, 9, 11],
	Scale.DORIAN: [0, 2, 3, 5, 7, 9, 10],
	Scale.PHRYGIAN: [0, 1, 3, 5, 7, 8, 10],
	Scale.LYDIAN: [0, 2, 4, 6, 7, 9, 11],
	Scale.MIXOLYDIAN: [0, 2, 4, 5, 7, 9, 10],
	Scale.LOCRIAN: [0, 1, 3, 5, 6, 8, 10],
	Scale.PENTATONIC_MAJOR: [0, 2, 4, 7, 9],
	Scale.PENTATONIC_MINOR: [0, 3, 5, 7, 10],
	Scale.BLUES: [0, 3, 5, 6, 7, 10],
	Scale.BLUES_MAJOR: [0, 2, 3, 4, 7, 9],
	Scale.BEBOP_DOMINANT: [0, 2, 4, 5, 7, 9, 10, 11],
	Scale.BEBOP_MAJOR: [0, 2, 4, 5, 7, 8, 9, 11],
	Scale.WHOLE_TONE: [0, 2, 4, 6, 8, 10],
	Scale.CHROMATIC: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
	Scale.JAPANESE: [0, 2, 3, 7, 8],  # Hirajoshi
	Scale.EGYPTIAN: [0, 2, 5, 7, 10],  # Suspended pentatonic
	Scale.HUNGARIAN_MINOR: [0, 2, 3, 6, 7, 8, 11],
	Scale.IRISH: [0, 2, 4, 5, 7, 9],  # Hexatonic, common in Irish trad
}

func get_scale_notes(start_midi: int, scale_type: Scale, num_notes: int = 16) -> Array:
	"""
	Generate a list of MIDI notes in a given scale.
	
	Args:
		start_midi: Starting MIDI note number (e.g., 60 for middle C)
		scale_type: Scale enum value
		num_notes: How many notes to generate (default 16)
	
	Returns:
		Array of MIDI note numbers
	"""
	var intervals = scale_intervals[scale_type]
	var notes = []
	
	var octave = 0
	var scale_index = 0
	
	for i in range(num_notes):
		# Calculate the MIDI note
		var note = start_midi + intervals[scale_index] + (octave * 12)
		notes.append(note)
		
		# Move to next note in scale
		scale_index += 1
		
		# If we've gone through all intervals, go to next octave
		if scale_index >= intervals.size():
			scale_index = 0
			octave += 1
	
	return notes


var midi_notes = []

# Example usage for your sequencer:
func setup_note_grid():
	# Start at C3 (MIDI 48) with a minor pentatonic scale	
	midi_notes = get_scale_notes(root_note, Scale.PENTATONIC_MINOR)
	
	# Or for Irish trad feel, start at D4 with Irish hexatonic
	# var midi_notes = get_scale_notes(62, Scale.IRISH)  # D4
	
	# Now midi_notes[row] gives you the MIDI note for that row
	for row in range(notes):
		var midi_note = midi_notes[row]
		print("Row %d = MIDI note %d" % [row, midi_note])


@onready var mm:MultiMeshInstance3D = $MultiMeshInstance3D

func test_sequence():
	sequence[0][0] = Step.ON
	sequence[4][5] = Step.ON
	sequence[5][7] = Step.ON
	sequence[1][8] = Step.ON
	sequence[1][2] = Step.ON
	sequence[3][3] = Step.ON
	sequence[3][4] = Step.ON
	sequence[2][6] = Step.ON

func initialise_sequence(rows, cols):
	for i in range(rows):
		var row = []
		for j in range(cols):
			row.append(Step.OFF)
		sequence.append(row)
	
func _process(delta: float) -> void:
	pass

func assign_colors():
	var i = 0
	for col in range(steps):				
		for row in range(notes):
			var c
			match sequence[row][col]:
				Step.OFF:
					c = out_color
				Step.ON:
					c = in_color
				Step.HIT_ON:
					c = hit_color
					sequence[row][col] = Step.ON
				Step.HIT_OFF:
					c = hit_color
					sequence[row][col] = Step.OFF
			mm.multimesh.set_instance_color(i, c)
			i += 1



var asp_index = 0

func print_sequence():
	print()
	for row in range(notes -1, -1, -1):
		var s = ""
		for col in range(steps):
			s += "1" if sequence[row][col] else "0" 
		print(s)
		
func play_sample(e, row, col):
	
	# Potential race condition!!!!
	# Great example
	change_instrument(midi_channel, instrument)
	
	var note = midi_notes[row]
	# print("play sample:" + str(i))
	var m = InputEventMIDI.new()
	m.message = MIDI_MESSAGE_NOTE_ON
	m.pitch = note
	m.velocity = 100
	m.channel = midi_channel
	
	print("Note: " + str(note) + " Channel: " + str(midi_channel))
		
	midi_player.receive_raw_midi_message(m)	
				
	
	
	
func hand_entered(area, row, col):
	print("Strike " + str(row) + " " + str(col))
	var hand = area.get_parent().get_parent().get_parent().get_parent().get_parent()
	if hand.gesture == "Index Pinch":
		sequence[row][col] = Step.ON if sequence[row][col] == Step.OFF else Step.OFF 
		mm.multimesh.set_instance_color((col * notes) + row, in_color)	
	else:
		mm.multimesh.set_instance_color((col * notes) + row, hit_color)	
	play_sample(0, row, col)
	
func note_off(note):
	var m = InputEventMIDI.new()
	m.message = MIDI_MESSAGE_NOTE_OFF
	m.pitch = note
	m.velocity = 0
	m.instrument = instrument
	m.channel = midi_channel
	midi_player.receive_raw_midi_message(m)

func hand_exited(area, row, col):
	var hand = area.get_parent().get_parent().get_parent().get_parent().get_parent()	
	if sequence[row][col] != Step.ON:
		mm.multimesh.set_instance_color((col * notes) + row, out_color)	
	else:
		mm.multimesh.set_instance_color((col * notes) + row, in_color)	
	note_off(midi_notes[row])

var s = 0.08
var spacer = 1.1

func make_sequencer():	
	
	mm.multimesh.instance_count = steps * notes
	var i = 0 
	for col in range(steps):				
		for row in range(notes):
			var pad = pad_scene.instantiate()
			
			var p = Vector3(s * col * spacer, s * row * spacer, 0)
			pad.position = p		
			# pad.rotation = rotation
			#var tm = TextMesh.new()
			#tm.font = font
			#tm.font_size = 1
			#tm.depth = 0.005
			## tm.text = str(row) + "," + str(col)
			#tm.text = file_names[row]
			#pad.get_node("MeshInstance3D2").mesh = tm
			var t = Transform3D()
			
			var s1 = 0.7
			t = t.scaled(Vector3(s * s1, s * s1, s * s1))
			t.origin = p
			mm.multimesh.set_instance_transform(i, t)
			i += 1
			pad.area_entered.connect(hand_entered.bind(row, col))
			pad.area_exited.connect(hand_exited.bind(row, col))
			add_child(pad)

func play_sample_gate(e, row, col, duration):
	var note = midi_notes[row]
	play_sample(e, row, col)	
	await get_tree().create_timer(duration - 0.2).timeout
	note_off(note)

func play_step(col):
	var p = Vector3(s * col * spacer, s * -1 * spacer, 0)
			
	$timer_ball.position = p
	for row in range(notes):
		if sequence[row][col]:
			mm.multimesh.set_instance_color((col * notes) + row, hit_color)	
			play_sample_gate(0, row, col, 1)		
			await get_tree().create_timer(0.2).timeout
			if sequence[row][col] == Step.ON:
				mm.multimesh.set_instance_color((col * notes) + row, in_color)	
			else:
				mm.multimesh.set_instance_color((col * notes) + row, out_color)	
					

var step_index:int = 0

func _on_timer_timeout() -> void:
	play_step(step_index)
	step_index = (step_index + 1) % steps
	pass # Replace with function body.


func _on_start_stop_area_entered(area: Area3D) -> void:
	# $"../sequencer/Timer".start()
	
	if $Timer.is_stopped():
		start.emit()
		$Timer.start()
	else:
		stop.emit()
		$Timer.stop()
	pass # Replace with function body.

func _on_up_area_entered(area: Area3D) -> void:
	root_note = root_note + 12
	midi_notes = get_scale_notes(root_note, mucical_scale)

	pass # Replace with function body.


func _on_down_area_entered(area: Area3D) -> void:
	root_note = root_note - 12
	midi_notes = get_scale_notes(root_note, mucical_scale)
	pass # Replace with function body.
	
	
	
	


func _on_scale_area_entered(area: Area3D) -> void:
	mucical_scale = (mucical_scale + 1) % Scale.size()
	print("Scale: " + str(mucical_scale))
	midi_notes = get_scale_notes(root_note, mucical_scale)
	pass # Replace with function body.


func _on_up_semi_area_entered(area: Area3D) -> void:
	root_note += 1
	midi_notes = get_scale_notes(root_note, mucical_scale)	
	pass # Replace with function body.


func _on_down_semi_area_entered(area: Area3D) -> void:
	root_note -= 1
	midi_notes = get_scale_notes(root_note, mucical_scale)
	pass # Replace with function body.


func _on_scale_down_area_entered(area: Area3D) -> void:
	mucical_scale = mucical_scale - 1
	if mucical_scale < 0:
		mucical_scale = Scale.size() -1
	print("Scale: " + str(mucical_scale))
	midi_notes = get_scale_notes(root_note, mucical_scale)
	pass # Replace with function body.


func _on_inst_up_area_entered(area: Area3D) -> void:
	instrument = (instrument + 1) % 127
	print(instrument)
	pass # Replace with function body.


func _on_inst_down_area_entered(area: Area3D) -> void:
	instrument = (instrument - 1)
	if instrument < 0:
		instrument = 127
	pass # Replace with function body.
