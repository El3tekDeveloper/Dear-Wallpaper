extends Node

func popup_window(window_size:= Vector2i(400, 200), window_title:= "Window") -> MarginContainer:
	var window = Window.new()
	var margin = InterfaceServer.create_margin_container(0, window)
	var panel = InterfaceServer.create_container_panel(window_size, InterfaceServer.create_custom_style(Color.WHEAT, Color.WHITE, 0, 0), margin, {
		anchor_left = 0.0, anchor_right = 1.0, offset_left = 0.0, offset_right = 0.0,
		anchor_top = 0.0, anchor_bottom = 1.0, offset_top = 0.0, offset_bottom = 0.0})
	InterfaceServer.add_shader(panel, preload("res://Shaders/Backgorund.gdshader"))
	var margin2 = InterfaceServer.create_margin_container(20, panel)
	
	window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	window.size = window_size
	window.title = window_title
	window.unresizable = true
	window.close_requested.connect(on_window_close_request.bind(window))
	
	add_child(window)
	
	return margin2

func create_file_dialog_window(file_mode:= FileDialog.FILE_MODE_OPEN_FILES, filters:= PackedStringArray(), window_size:= Vector2(800, 500), title:= "Open Files", perent: Node = null) -> FileDialog:
	
	var file_dialog: FileDialog = FileDialog.new()
	
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = file_mode
	for filter in filters:
		file_dialog.add_filter("*%s*" % filter)
	file_dialog.size = window_size
	file_dialog.title = title
	
	var close_func = on_window_close_request.bind(file_dialog)
	file_dialog.close_requested.connect(close_func)
	file_dialog.canceled.connect(close_func)
	file_dialog.confirmed.connect(close_func)
	file_dialog.dir_selected.connect(func(selected): close_func.call())
	file_dialog.file_selected.connect(func(selected): close_func.call())
	file_dialog.files_selected.connect(func(selected): close_func.call())
	
	if perent == null: add_child(file_dialog)
	else: perent.add_child(file_dialog)
	
	file_dialog.popup_centered()
	return file_dialog

func emit_close_window(window: Window) -> void:
	window.close_requested.emit()

func on_window_close_request(window: Window) -> void:
	window.queue_free()
