extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and event.ctrl_pressed:
			reset_app()

func reset_app() -> void:
	get_tree().reload_current_scene()
