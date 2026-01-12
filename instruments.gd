extends Node3D


func _on_start_stop_area_entered(area: Area3D) -> void:
	if $Timer.is_stopped():
		$"Timer".start()
	else:
		$"Timer".stop()
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	$sequencer.next_step()
	$sequencer2.next_step()
	$drums.next_step()
	pass # Replace with function body.
