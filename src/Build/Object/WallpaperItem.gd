class_name WallpaperItem extends VBoxContainer

var image_display: TextureRect
var title_label: Label
var download_button: TextureButton
var favorite_button: TextureButton
var lowlight: ColorRect
var loading: ColorRect

var item_res: WallpaperItemRes = WallpaperItemRes.new()

var is_hovered: bool = false
var original_scale: Vector2
var hover_scale: Vector2 = Vector2(1.05, 1.05)

var glow_color: Color = Color(0.0, 0.588, 1.0, 0.2)
var glow_intensity: float = 0.0
var glow_thickness: float = 9.0

var tweener: TweenerComponent

func _init() -> void:
	tweener = TweenerComponent.new()
	add_child(tweener)
	original_scale = scale
	
	setup_ui()
	connect_signals()

func setup_ui() -> void:
	add_theme_constant_override("separation", 0)
	var panel_style = InterfaceServer.create_custom_style(
		Color(0.18, 0.18, 0.18), Color.WHITE, 0, 0,
		{"corner_radius_top_left": 25, "corner_radius_top_right": 25})
	
	var display_panel = InterfaceServer.create_container_panel(Vector2.ZERO, panel_style, self, {clip_children = CLIP_CHILDREN_AND_DRAW})
	image_display = InterfaceServer.create_texture_rect(Vector2(240.0, 160.0), null, display_panel, {
		expand_mode = TextureRect.EXPAND_IGNORE_SIZE,
		stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED})
	InterfaceServer.add_shader(image_display, preload("res://Shaders/ShaderShine.gdshader"))
	
	lowlight = InterfaceServer.create_color_rect(Color(0.0, 0.0, 0.0, 0.47), display_panel, {mouse_filter = Control.MOUSE_FILTER_IGNORE, size_flags_vertical = Control.SIZE_EXPAND_FILL, size_flags_horizontal = Control.SIZE_EXPAND_FILL})
	lowlight.modulate.a = 0.0
	
	favorite_button = InterfaceServer.create_texture_button(preload("res://Assets/Icons/star.png"), lowlight, {
		size_flags_vertical = SIZE_SHRINK_CENTER, ize_flags_horizontal = SIZE_SHRINK_CENTER,
		anchor_left = 1.0, anchor_right = 1.0, anchor_top = 0.0, anchor_bottom = 0.0,
		offset_left = -34, offset_top = 8, offset_right = 0, offset_bottom = 0})
	
	var type_icon = InterfaceServer.create_texture_rect(Vector2(35, 35), preload("res://Assets/Icons/insert-picture-icon.png"), lowlight, {
		expand_mode = TextureRect.EXPAND_IGNORE_SIZE,
		stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED,
		anchor_left = 0.5, anchor_top = 0.5, anchor_right = 0.5, anchor_bottom = 0.5,
		offset_left = -17.5, offset_top = -17.5, offset_right = 17.5, offset_bottom = 17.5, mouse_filter = Control.MOUSE_FILTER_IGNORE})
	
	loading = InterfaceServer.create_color_rect(Color.WHITE, display_panel, {size_flags_vertical = Control.SIZE_EXPAND_FILL, size_flags_horizontal = Control.SIZE_EXPAND_FILL})
	loading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	InterfaceServer.add_shader(loading, preload("res://Shaders/Loading.gdshader"))
	
	var ui_panel = InterfaceServer.create_panel(Vector2(0, 35), preload("res://UI&UX/BottomMainPanel.tres"), self)
	var margin = InterfaceServer.create_margin_container(0, ui_panel, {
		anchor_left = 0.0, anchor_right = 1.0, offset_left = 0.0, offset_right = 0.0,
		anchor_top = 0.0, anchor_bottom = 1.0, offset_top = 0.0, offset_bottom = 0.0})
	margin.add_theme_constant_override("margin_left", 25); margin.add_theme_constant_override("margin_right", 25)
	
	var hbox = InterfaceServer.create_box_container(0, false, margin)
	title_label = InterfaceServer.create_label(item_res.get_filename(), 19, InterfaceServer.label_settings, hbox, {size_flags_horizontal = Control.SIZE_EXPAND_FILL})
	download_button = InterfaceServer.create_texture_button(preload("res://Assets/Icons/downloads.png"), hbox, {size_flags_vertical = SIZE_SHRINK_CENTER})

func _draw() -> void:
	if !is_hovered: return
	if glow_intensity > 0.0:
		var rect = Rect2(Vector2.ZERO, size)
		var corner_radius = 25.0
		
		for i in range(int(glow_thickness)):
			var alpha = glow_intensity * (1.0 - float(i) / glow_thickness)
			var current_color = Color(glow_color.r, glow_color.g, glow_color.b, alpha)
			var outline_rect = rect.grow(i + 1)
			
			draw_rounded_outline(outline_rect, corner_radius + i, current_color, 1.0)

func draw_rounded_outline(rect: Rect2, radius: float, color: Color, width: float) -> void:
	var points = []
	var segments = 50
	
	for i in range(segments * 4):
		var angle = float(i) / (segments * 4) * TAU
		var corner_index = int(i / segments)
		var local_angle = (float(i % segments) / float(segments)) * PI * 0.5
		
		var center = Vector2()
		match corner_index:
			0:  # Top-right
				center = Vector2(rect.position.x + rect.size.x - radius, rect.position.y + radius)
				angle = -PI * 0.5 + local_angle
			1:  # Bottom-right
				center = Vector2(rect.position.x + rect.size.x - radius, rect.position.y + rect.size.y - radius)
				angle = 0.0 + local_angle
			2:  # Bottom-left
				center = Vector2(rect.position.x + radius, rect.position.y + rect.size.y - radius)
				angle = PI * 0.5 + local_angle
			3:  # Top-left
				center = Vector2(rect.position.x + radius, rect.position.y + radius)
				angle = PI + local_angle
		
		var point = center + Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
	
	if points.size() > 2:
		for i in range(points.size()):
			var next_i = (i + 1) % points.size()
			draw_line(points[i], points[next_i], color, width)

func connect_signals() -> void:
	image_display.mouse_filter = Control.MOUSE_FILTER_PASS
	image_display.connect("mouse_entered", Callable(self, "on_mouse_entered"))
	image_display.connect("mouse_exited", Callable(self, "on_mouse_exited"))
	
	favorite_button.mouse_filter = Control.MOUSE_FILTER_PASS
	favorite_button.connect("mouse_entered", Callable(self, "on_mouse_entered"))
	favorite_button.connect("mouse_exited", Callable(self, "on_mouse_exited"))
	favorite_button.connect("pressed",  Callable(self, "on_favorite_button_pressed"))
	
	image_display.connect("gui_input", Callable(self, "_on_image_gui_input"))
	download_button.pressed.connect(func():
		var file_dialog = WindowManager.create_file_dialog_window(
			FileDialog.FILE_MODE_OPEN_DIR, [], Vector2(800, 500), "Save Folder"
		)
		file_dialog.dir_selected.connect(func(selected_path: String):
			if selected_path == "": push_error("No save path selected"); return
			
			item_res.save_image(selected_path, self)
		)
		file_dialog.popup())

func _on_image_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		change_wallpaper_popup()

func on_mouse_entered() -> void:
	is_hovered = true
	pivot_offset = size * 0.5
	tweener.play_tween(self, "scale", [hover_scale], [0.2])
	tweener.play_tween(self, "glow_intensity", [0.5], [0.3])
	tweener.play_tween(lowlight, "modulate:a", [1], [0.2])
	queue_redraw()
	
func on_mouse_exited() -> void:
	is_hovered = false
	tweener.play_tween(self, "scale", [original_scale], [0.15])
	tweener.play_tween(self, "glow_intensity", [0.0], [0.2])
	tweener.play_tween(lowlight, "modulate:a", [0.0], [0.2])
	queue_redraw()

func on_favorite_button_pressed():
	if favorite_button.texture_normal == preload("res://Assets/Icons/star.png"): 
		favorite_button.texture_normal = preload("res://Assets/Icons/favorite.png")
	else:
		favorite_button.texture_normal = preload("res://Assets/Icons/star.png")

func _on_glow_intensity_changed():
	queue_redraw()

func change_wallpaper_popup():
	if !item_res.has_image(): return
	
	var window = WindowManager.popup_window(Vector2(435, 423), "Change Wallpaper")
	var panel = InterfaceServer.create_container_panel(Vector2.ZERO, preload("res://UI&UX/FullMainPanel.tres"), window)
	var margin = InterfaceServer.create_margin_container(8, panel)
	var vbox = InterfaceServer.create_box_container(5, true, margin)
	
	var wallpaper_image = InterfaceServer.create_texture_rect(
		Vector2(240.0, 240.0), 
		ImageTexture.create_from_image(item_res.image), 
		vbox, {
			expand_mode = TextureRect.EXPAND_IGNORE_SIZE,
			stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		}
	)
	InterfaceServer.add_shader(wallpaper_image, preload("res://Shaders/CornerRadius.gdshader"))
	
	InterfaceServer.create_h_separator(10, vbox)
	var project_name = ProjectSettings.get_setting("application/config/name")
	var default_save_path = OS.get_environment("APPDATA") + "\\" + project_name + "\\Wallpapers"
	if not DirAccess.dir_exists_absolute(default_save_path):
		DirAccess.make_dir_recursive_absolute(default_save_path)
	
	var save_path_hbox = InterfaceServer.create_box_container(6, false, vbox)
	var savepath = InterfaceServer.create_line_edit("Save Path... ", null, save_path_hbox, {size_flags_horizontal = SIZE_EXPAND_FILL})
	savepath.text = default_save_path
	
	var file_btn = InterfaceServer.create_texture_button(preload("res://Assets/Icons/folder.png"), save_path_hbox, {}, true)
	file_btn.pressed.connect(func(): 
		var file_dialog = WindowManager.create_file_dialog_window(FileDialog.FILE_MODE_OPEN_DIR, [], Vector2(800, 500), "Save Folder", window)
		file_dialog.dir_selected.connect(func(selected_path): 
			savepath.text = selected_path
		)
	)
	
	InterfaceServer.create_h_separator(10, vbox, {size_flags_vertical = Container.SIZE_EXPAND_FILL, modulate = Color(0, 0, 0, 0)})
	var change_hbox = InterfaceServer.create_box_container(6, false, vbox, {size_flags_horizontal = Container.SIZE_SHRINK_CENTER})
	var cancel_btn = InterfaceServer.create_button(Vector2(100, 32), false, "Cancel", null, change_hbox)
	var apply_btn = InterfaceServer.create_button(Vector2(100, 32), true, "Apply", null, change_hbox)
	
	apply_btn.pressed.connect(func():
		var final_path = savepath.text.strip_edges()
		final_path = final_path.replace("/", "\\")
		
		if final_path == "":
			push_error("No save path selected")
			return
		
		if not DirAccess.dir_exists_absolute(final_path):
			var err = DirAccess.make_dir_recursive_absolute(final_path)
			if err != OK:
				push_error("Cannot create directory: " + final_path)
				return
		
		item_res.save_image(final_path, self)
		item_res.image_saved.connect(func(path): 
			print("Wallpaper saved at: ", path)
			var wallpaper_res = WallpaperRes.new()
			wallpaper_res.ChangeWallpaper(path)
			WindowManager.emit_close_window(window.get_window())
		)
	)
	
	cancel_btn.pressed.connect(func(): WindowManager.emit_close_window(window.get_window()))

func update_ui():
	if !item_res.has_image(): return
	title_label.text = item_res.get_filename()
	var image_texture = ImageTexture.create_from_image(item_res.image)
	image_display.texture = image_texture

func set_data(res: WallpaperItemRes) -> void:
	item_res = res
	title_label.text = item_res.get_filename()
	if item_res.has_image():
		image_display.texture = ImageTexture.create_from_image(item_res.image)
		item_res.image_changed.emit(item_res)
		loading.hide()
	else:
		loading.show()
