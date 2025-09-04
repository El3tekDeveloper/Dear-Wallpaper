class_name CustomLineEdit extends LineEdit

var normal_bg_color: Color = Color(0.188, 0.212, 0.239, 0.5) 
var normal_border_color: Color = Color(0.188, 0.212, 0.239, 0.8)
var focus_bg_color: Color = Color(0.188, 0.212, 0.239, 0.8)
var focus_border_color: Color = Color(0.0, 0.588, 1.0, 1.0)
var focus_glow_color: Color = Color(0.0, 0.588, 1.0, 0.1)
var text_color: Color = Color(0.788, 0.820, 0.851, 1.0)
var placeholder_color: Color = Color(0.431, 0.463, 0.506, 1.0)

var transition_duration: float = 0.2
var glow_size: float = 3.0
var border_radius: float = 6.0

var tween: Tween
var current_bg_color: Color
var current_border_color: Color
var is_focused: bool = false
var trailing_icon: Texture2D

signal action_triggered(value: String)
signal cleared()

func _init():
	custom_minimum_size = Vector2(250, 40)
	
	current_bg_color = normal_bg_color
	current_border_color = normal_border_color
		
	trailing_icon = _create_default_icon()
	
	call_deferred("_setup_line_edit")

func _setup_line_edit():
	if not focus_entered.is_connected(_on_focus_entered):
		focus_entered.connect(_on_focus_entered)
	if not focus_exited.is_connected(_on_focus_exited):
		focus_exited.connect(_on_focus_exited)
	
	_apply_styling()

func _apply_styling():
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = current_bg_color
	style_normal.border_color = current_border_color
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(border_radius)
	style_normal.content_margin_left = 15
	style_normal.content_margin_right = 40
	style_normal.content_margin_top = 10
	style_normal.content_margin_bottom = 10
	
	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = current_bg_color
	style_focus.border_color = current_border_color
	style_focus.set_border_width_all(1)
	style_focus.set_corner_radius_all(border_radius)
	style_focus.content_margin_left = 15
	style_focus.content_margin_right = 40
	style_focus.content_margin_top = 10
	style_focus.content_margin_bottom = 10
	
	if is_focused:
		style_focus.shadow_color = focus_glow_color
		style_focus.shadow_size = glow_size
		style_focus.shadow_offset = Vector2.ZERO
	
	add_theme_stylebox_override("normal", style_normal)
	add_theme_stylebox_override("focus", style_focus)
	
	add_theme_color_override("font_color", text_color)
	add_theme_color_override("font_placeholder_color", placeholder_color)
	add_theme_color_override("font_selected_color", Color.WHITE)
	add_theme_color_override("selection_color", Color(focus_border_color.r, focus_border_color.g, focus_border_color.b, 0.3))

func _on_focus_entered():
	is_focused = true
	_animate_to_focus_state()

func _on_focus_exited():
	is_focused = false
	_animate_to_normal_state()

func _animate_to_focus_state():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_method(_update_bg_color, current_bg_color, focus_bg_color, transition_duration)
	tween.tween_method(_update_border_color, current_border_color, focus_border_color, transition_duration)

func _animate_to_normal_state():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_method(_update_bg_color, current_bg_color, normal_bg_color, transition_duration)
	tween.tween_method(_update_border_color, current_border_color, normal_border_color, transition_duration)

func _update_bg_color(color: Color):
	current_bg_color = color
	_apply_styling()

func _update_border_color(color: Color):
	current_border_color = color
	_apply_styling()

func _draw():
	if trailing_icon:
		var icon_size = Vector2(16, 16)
		var icon_pos = Vector2(
			size.x - icon_size.x - 12,
			(size.y - icon_size.y) / 2
		)
		
		var icon_color = placeholder_color if text.is_empty() else text_color
		draw_texture_rect(trailing_icon, Rect2(icon_pos, icon_size), false, icon_color)

func _input(event):
	if has_focus() and event is InputEventKey:
		var key_event = event as InputEventKey
		
		if key_event.pressed and key_event.keycode == KEY_ENTER:
			if not text.is_empty():
				action_triggered.emit(text)
		
		elif key_event.pressed and key_event.keycode == KEY_ESCAPE:
			clear_content()

func clear_content():
	text = ""
	release_focus()
	cleared.emit()

func _create_default_icon() -> ImageTexture:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = Vector2(6, 6)
	var radius = 4
	
	for y in range(16):
		for x in range(16):
			var pos = Vector2(x, y)
			var distance = pos.distance_to(center)
			
			if abs(distance - radius) < 0.8:
				image.set_pixel(x, y, placeholder_color)
	
	for i in range(4):
		var handle_x = 10 + i
		var handle_y = 10 + i
		if handle_x < 16 and handle_y < 16:
			image.set_pixel(handle_x, handle_y, placeholder_color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func set_colors(normal_bg: Color, normal_border: Color, focus_bg: Color, focus_border: Color):
	normal_bg_color = normal_bg
	normal_border_color = normal_border
	focus_bg_color = focus_bg
	focus_border_color = focus_border
	current_bg_color = normal_bg_color
	current_border_color = normal_border_color
	if is_inside_tree():
		_apply_styling()

func set_trailing_icon(icon: Texture2D):
	trailing_icon = icon
	queue_redraw()

func _set_placeholder(text: String):
	placeholder_text = text
