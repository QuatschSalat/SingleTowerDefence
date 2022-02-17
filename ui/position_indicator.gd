extends Area2D

signal position_indicator_pressed(click_position)

# Signals
func _on_mouse_entered():
	$AnimationPlayer.play("hover")
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	$AnimationPlayer.play("RESET")
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			$AnimationPlayer.play("press")
			emit_signal('position_indicator_pressed', global_position)
		elif not event.pressed:
			$AnimationPlayer.play("RESET")
