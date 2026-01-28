extends Marker3D

@export var font:Font 

var sequence = []
var notes_in_cell = []
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
@export var step_color:Color

enum Step {OFF, ON, HIT_ON, HIT_OFF}


@export var instrument:int = 1
@export var midi_channel:int = 1
@export var root_note:int = 68

@onready var midi_player:MidiPlayer = $"MidiPlayer"

@export var label_scene:PackedScene

func midi_note_to_string(midi_num: int) -> String:
	var notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	var octave = (midi_num / 12) - 1
	var note_name = notes[midi_num % 12]
	return note_name + str(octave)
	
var instruments = [
		# 1-8 Piano
		"Acoustic Grand Piano", "Bright Acoustic Piano", "Electric Grand Piano", "Honky-tonk Piano",
		"Electric Piano 1", "Electric Piano 2", "Harpsichord", "Clavi",
		# 9-16 Chromatic Percussion
		"Celesta", "Glockenspiel", "Music Box", "Vibraphone", "Marimba", "Xylophone", "Tubular Bells", "Dulcimer",
		# 17-24 Organ
		"Drawbar Organ", "Percussive Organ", "Rock Organ", "Church Organ", "Reed Organ", "Accordion", "Harmonica", "Tango Accordion",
		# 25-32 Guitar
		"Acoustic Guitar (nylon)", "Acoustic Guitar (steel)", "Electric Guitar (jazz)", "Electric Guitar (clean)",
		"Electric Guitar (muted)", "Overdriven Guitar", "Distortion Guitar", "Guitar harmonics",
		# 33-40 Bass
		"Acoustic Bass", "Electric Bass (finger)", "Electric Bass (pick)", "Fretless Bass", "Slap Bass 1", "Slap Bass 2", "Synth Bass 1", "Synth Bass 2",
		# 41-48 Strings
		"Violin", "Viola", "Cello", "Contrabass", "Tremolo Strings", "Pizzicato Strings", "Orchestral Harp", "Timpani",
		# 49-56 Ensemble
		"String Ensemble 1", "String Ensemble 2", "SynthStrings 1", "SynthStrings 2", "Choir Aahs", "Voice Oohs", "Synth Voice", "Orchestra Hit",
		# 57-64 Brass
		"Trumpet", "Trombone", "Tuba", "Muted Trumpet", "French Horn", "Brass Section", "SynthBrass 1", "SynthBrass 2",
		# 65-72 Reed
		"Soprano Sax", "Alto Sax", "Tenor Sax", "Baritone Sax", "Oboe", "English Horn", "Bassoon", "Clarinet",
		# 73-80 Pipe
		"Piccolo", "Flute", "Recorder", "Pan Flute", "Blown Bottle", "Shakuhachi", "Whistle", "Ocarina",
		# 81-88 Lead
		"Lead 1 (square)", "Lead 2 (sawtooth)", "Lead 3 (calliope)", "Lead 4 (chiff)", "Lead 5 (charang)", "Lead 6 (voice)", "Lead 7 (fifths)", "Lead 8 (bass + lead)",
		# 89-96 Pad
		"Pad 1 (new age)", "Pad 2 (warm)", "Pad 3 (polysynth)", "Pad 4 (choir)", "Pad 5 (bowed)", "Pad 6 (metallic)", "Pad 7 (halo)", "Pad 8 (sweep)",
		# 97-104 Effects
		"FX 1 (rain)", "FX 2 (soundtrack)", "FX 3 (crystal)", "FX 4 (atmosphere)", "FX 5 (brightness)", "FX 6 (goblins)", "FX 7 (echoes)", "FX 8 (sci-fi)",
		# 105-112 Ethnic
		"Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bag pipe", "Fiddle", "Shanai",
		# 113-120 Percussive
		"Tinkle Bell", "Agogo", "Steel Drums", "Woodblock", "Taiko Drum", "Melodic Tom", "Synth Drum", "Reverse Cymbal",
		# 121-128 Sound Effects
		"Guitar Fret Noise", "Breath Noise", "Seashore", "Bird Tweet", "Telephone Ring", "Helicopter", "Applause", "Gunshot"
	]

func change_instrument(channel: int, program: int):
	var midi_event = InputEventMIDI.new()
	midi_event.channel = channel
	midi_event.message = MIDI_MESSAGE_PROGRAM_CHANGE
	midi_event.instrument = program
	midi_player.receive_raw_midi_message(midi_event)

func _ready():
	initialise_sequence(notes, steps)
	make_sequencer()
	
	in_color = Color.from_hsv(randf(), 1, 1, 0.5)
	out_color = Color.from_hsv(fmod(in_color.h + 0.3, 1.0), 1, 1, 0.5)
	hit_color = Color.from_hsv(fmod(out_color.h + 0.3, 1.0), 1, 1, 0.5)
	step_color = Color.from_hsv(fmod(hit_color.h + 0.3, 1.0), 1, 1, 0.5)
	
	assign_colors()
	create_labels()
	midi_notes = get_scale_notes(root_note, mucical_scale)	
	change_instrument(midi_channel, instrument)
	
var labels = []
	
func create_labels():
	for row in range(notes):
		var label:Label3D = label_scene.instantiate()		
		var p = Vector3(s * -0.5 * spacer, s * row * spacer, 0)
		label.position = p		
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		add_child(label)
		labels.push_back(label)
		
		label = label_scene.instantiate()		
		p = Vector3(s * (steps + 0.1) * spacer, s * row * spacer, 0)
		label.position = p		
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		add_child(label)
		labels.push_back(label)

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
	JAPANESE,
	EGYPTIAN,
	HUNGARIAN_MINOR,
	IRISH,
}

@export var mucical_scale:Scale = Scale.PENTATONIC_MINOR

var scale_intervals = {
	Scale.MAJOR: [0, 2, 4, 5, 7, 9, 11],
	Scale.MINOR: [0, 2, 3, 5, 7, 8, 10],
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
	Scale.JAPANESE: [0, 2, 3, 7, 8],
	Scale.EGYPTIAN: [0, 2, 5, 7, 10],
	Scale.HUNGARIAN_MINOR: [0, 2, 3, 6, 7, 8, 11],
	Scale.IRISH: [0, 2, 4, 5, 7, 9],
}

func get_scale_notes(start_midi: int, scale_type: Scale, num_notes: int = 16) -> Array:
	var intervals = scale_intervals[scale_type]
	var notes = []
	
	var octave = 0
	var scale_index = 0
	
	for i in range(num_notes):
		var note = start_midi + intervals[scale_index] + (octave * 12)
		notes.append(note)
		labels[i*2].text = midi_note_to_string(note)
		labels[i*2 + 1].text = midi_note_to_string(note)
		
		scale_index += 1
		if scale_index >= intervals.size():
			scale_index = 0
			octave += 1
	
	return notes

var midi_notes = []

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
		var row1 = []
		for j in range(cols):
			row.append(Step.OFF)
			row1.append(-1)
		sequence.append(row)
		notes_in_cell.append(row1)
	
func _process(delta: float) -> void:
	update_labels()
	
	for note in exit_queue:
		note_off(note)
	exit_queue.clear()
	
	for note in enter_queue:
		note_on(note)
	enter_queue.clear()
	
var is_blinking:bool = false

func start_color_blink(label):
	is_blinking = true
	while is_blinking:
		label.modulate = blink_on
		await get_tree().create_timer(0.25).timeout
		if not is_blinking:
			break
		label.modulate = blink_off
		await get_tree().create_timer(0.25).timeout

func get_midi_instrument_name(program_num: int) -> String:
	if program_num < 0 or program_num > 127:
		return "Unknown Instrument"
	return instruments[program_num]

func update_labels():
	$controls/instrument.text = get_midi_instrument_name(instrument)
	$controls/root.text = midi_note_to_string(root_note)
	$controls/root2.text = midi_note_to_string(root_note)
	$controls/mode.text = str(Scale.keys()[mucical_scale]).replace("_", " ")
	$controls/direction.text = str(Direction.keys()[playback_direction])
	$controls/mute.text = "UNMUTE" if stopped else "MUTE"

	if direction_change_requested and not is_blinking:
		start_color_blink($controls/dir)
		start_color_blink($controls/direction)
	elif not direction_change_requested:
		is_blinking = false
		$controls/dir.modulate = blink_off
		$controls/direction.modulate = blink_off

var blink_off = Color(0.0, 6.436, 4.693, 0.792)
var blink_on = Color(5.049, 1.406, 6.271, 0.792)

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
		
var hit_note:int = -1
		
func play_sample(e, row, col):
	var note = midi_notes[row]	
	note_on(note)
				
var exit_queue = []
var enter_queue = []
	
var active_cells = {}

func hand_entered(area, row, col):
	if not area.is_in_group("finger_tip"):
		return
	var hand = area.get_parent().get_parent().get_parent().get_parent().get_parent()
	if hand.gesture == "Index Pinch":
		sequence[row][col] = Step.ON if sequence[row][col] == Step.OFF else Step.OFF 
		mm.multimesh.set_instance_color((col * notes) + row, in_color)	
	else:
		mm.multimesh.set_instance_color((col * notes) + row, hit_color)	
	
	hit_note = midi_notes[row]
	
	if not active_cells.has(hit_note):
		active_cells[hit_note] = []
	
	enter_queue.append(hit_note)
	active_cells[hit_note].append([row, col])
	notes_in_cell[row][col] = hit_note

func hand_exited(area, row, col):
	if not area.is_in_group("finger_tip"):
		return
	var hand = area.get_parent().get_parent().get_parent().get_parent().get_parent()	
	if sequence[row][col] != Step.ON:
		mm.multimesh.set_instance_color((col * notes) + row, out_color)	
	else:
		mm.multimesh.set_instance_color((col * notes) + row, in_color)	

	hit_note = notes_in_cell[row][col]
	
	active_cells[hit_note].erase([row, col])
	
	if active_cells[hit_note].is_empty():
		exit_queue.append(hit_note)
	
func note_on(note):
	change_instrument(midi_channel, instrument)
	print("Note on: " + str(note))
	var m = InputEventMIDI.new()
	m.message = MIDI_MESSAGE_NOTE_ON
	m.pitch = note
	m.velocity = $controls/vel/grab.value
	m.channel = midi_channel			
	midi_player.receive_raw_midi_message(m)	
	
func note_off(note):
	print("Note off: " + str(note))	
	var m = InputEventMIDI.new()
	m.message = MIDI_MESSAGE_NOTE_OFF
	m.pitch = note
	m.velocity = 0
	m.instrument = instrument
	m.channel = midi_channel
	midi_player.receive_raw_midi_message(m)

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
	
	print("Note on: " + str(note) + " Channel: " + str(midi_channel))	
	play_sample(e, row, col)	
	await get_tree().create_timer(duration).timeout
	
	if not active_cells.has(note) or active_cells[note].is_empty():
		print("Note off: " + str(note) + " Channel: " + str(midi_channel))
		note_off(note)
	else:
		print("Skipping note off - hand is holding note: " + str(note))

var current_step_col:int = -1

func set_column_color(col:int, is_current:bool):
	for row in range(notes):
		var index = (col * notes) + row
		var color
		
		if is_current:
			# For current step: show hit_color for ON notes, step_color for OFF notes
			if sequence[row][col] == Step.ON:
				color = hit_color
			else:
				color = step_color
		else:
			# For non-current steps: normal colors
			match sequence[row][col]:
				Step.OFF:
					color = out_color
				Step.ON:
					color = in_color
				Step.HIT_ON:
					color = hit_color
					sequence[row][col] = Step.ON
				Step.HIT_OFF:
					color = hit_color
					sequence[row][col] = Step.OFF
		
		mm.multimesh.set_instance_color(index, color)

func play_step(col):
	# Reset previous column to normal colors
	if current_step_col >= 0:
		set_column_color(current_step_col, false)
	
	# Highlight current column
	set_column_color(col, true)
	current_step_col = col
	
	if stopped:
		return
		
	for row in range(notes):
		if sequence[row][col]:
			var gate = $controls/gate/grab.value
			play_sample_gate(0, row, col, gate)

var step_index:int = 0

var stopped = false

func _on_start_stop_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	stopped = ! stopped

func _on_up_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	if root_note + 12 < 128:
		root_note = root_note + 12
		midi_notes = get_scale_notes(root_note, mucical_scale)

func _on_down_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	if root_note - 12 >= 0:	
		root_note = root_note - 12
		midi_notes = get_scale_notes(root_note, mucical_scale)

func _on_scale_area_entered(area: Area3D) -> void:
	mucical_scale = (mucical_scale + 1) % Scale.size()
	print("Scale: " + str(mucical_scale))
	midi_notes = get_scale_notes(root_note, mucical_scale)

func _on_up_semi_area_entered(area: Area3D) -> void:
	if root_note < 127:
		root_note += 1
		midi_notes = get_scale_notes(root_note, mucical_scale)	

func _on_down_semi_area_entered(area: Area3D) -> void:
	if root_note > 0:
		root_note = root_note - 1
		midi_notes = get_scale_notes(root_note, mucical_scale)
	print("Root note: " + str(root_note))

func _on_scale_down_area_entered(area: Area3D) -> void:
	mucical_scale = mucical_scale - 1
	if mucical_scale < 0:
		mucical_scale = Scale.size() -1
	print("Scale: " + str(mucical_scale))
	midi_notes = get_scale_notes(root_note, mucical_scale)

func _on_inst_up_area_entered(area: Area3D) -> void:
	instrument = (instrument + 1) % 127
	print(instrument)

func _on_inst_down_area_entered(area: Area3D) -> void:
	instrument = (instrument - 1)
	if instrument < 0:
		instrument = 127

func _on_clear_area_entered(area: Area3D) -> void:
	for row in notes:
		for col in steps:
			sequence[row][col] = Step.OFF
	assign_colors()

enum Direction {FORWARD, BACKWARD, PING_PONG}

@export var playback_direction:Direction = Direction.FORWARD

var ping_pong_forward:bool = true

var direction_change_pending:Direction = Direction.FORWARD
var direction_change_requested:bool = false

func next_step() -> void:
	play_step(step_index)
	
	if direction_change_requested:
		if playback_direction == Direction.FORWARD and step_index == steps - 1:
			apply_direction_change()
		elif playback_direction == Direction.BACKWARD and step_index == 0:
			apply_direction_change()
		elif playback_direction == Direction.PING_PONG and (step_index == 0 or step_index == steps - 1):
			apply_direction_change()
	
	match playback_direction:
		Direction.FORWARD:
			step_index = (step_index + 1) % steps
			
		Direction.BACKWARD:
			step_index = step_index - 1
			if step_index < 0:
				step_index = steps - 1
				
		Direction.PING_PONG:
			if ping_pong_forward:
				if step_index == steps - 1:
					ping_pong_forward = false
				else:
					step_index += 1
			else:
				if step_index == 0:
					ping_pong_forward = true
				else:
					step_index -= 1

func apply_direction_change():
	var old_direction = playback_direction
	playback_direction = direction_change_pending
	direction_change_requested = false
	
	if old_direction == Direction.FORWARD and playback_direction == Direction.BACKWARD:
		step_index = steps - 1 - step_index
	elif old_direction == Direction.BACKWARD and playback_direction == Direction.FORWARD:
		step_index = steps - 1 - step_index

func _on_ping_pong_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	direction_change_pending = Direction.PING_PONG
	direction_change_requested = true
	print("Direction change queued: " + str(Direction.keys()[direction_change_pending]))

func _on_forwards_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	direction_change_pending = Direction.FORWARD
	direction_change_requested = true
	print("Direction change queued: " + str(Direction.keys()[direction_change_pending]))

func _on_backwards_area_entered(area: Area3D) -> void:
	if not area.is_in_group("finger_tip"):
		return
	direction_change_pending = Direction.BACKWARD
	direction_change_requested = true
	print("Direction change queued: " + str(Direction.keys()[direction_change_pending]))
