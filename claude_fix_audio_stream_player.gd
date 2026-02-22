extends AudioStreamPlayer

@onready var player: AudioStreamPlayer = $"."
var playback: AudioStreamGeneratorPlayback

func _ready():
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = AudioServer.get_input_mix_rate()
	gen.buffer_length = 0.1  # 100ms buffer
	player.stream = gen
	player.play()
	playback = player.get_stream_playback()
	AudioServer.set_input_device_active(true)

func _process(_delta):
	var available = AudioServer.get_input_frames_available()
	if available > 0:
		var frames = AudioServer.get_input_frames(available)
		playback.push_buffer(frames)
