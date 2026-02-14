extends Marker3D
var bpm:int

func _ready() -> void:
	bpm = $grab.value
	var seconds_per_beat = 60.0 / bpm
	$"../../../Timer".wait_time = seconds_per_beat / 4.0  # 16th notes!
	
func _process(delta: float) -> void:
	var new_bpm:int = $grab.value
	if self.bpm != new_bpm:
		self.bpm = new_bpm
		var seconds_per_beat = 60.0 / bpm
		$"../../../Timer".wait_time = seconds_per_beat / 4.0  # 16th notes!
