class_name SelectButton extends Button

var is_active: bool = false
var is_hovered: bool = false
var button_text: String = "Button"
var icon_texture: Texture2D

var bg_normal = Color(0.0, 0.0, 0.0, 0.0)
var bg_hover = Color(0.188, 0.212, 0.239, 0.5)
var bg_active = Color(0.0, 0.588, 1.0, 0.15)
var border_hover = Color(0.431, 0.467, 0.506, 1.0)
var border_active = Color(0.0, 0.588, 1.0, 0.3)
var text_normal = Color(0.788, 0.816, 0.851, 1.0)
var text_hover = Color(0.0, 0.588, 1.0, 1.0)
var text_active = Color(0.0, 0.588, 1.0, 1.0)
var accent_color = Color(0.0, 0.588, 1.0, 1.0)

var tweener: TweenerComponent
var scale_normal = Vector2.ONE
var scale_hover = Vector2(1.05, 1.05)
var left_border_scale = 0.0

var clip_container: Control
var left_border: ColorRect
var icon_rect: TextureRect

signal button_pressed_custom(button: SelectButton)

func _init():
	custom_minimum_size = Vector2(0, 44)
	text = button_text
	flat = true
	clip_contents = true
	_setup_styles()
	_setup_ui()
	_setup_tweener()

func _setup_styles():
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = bg_normal
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.border_width_left = 1
	normal_style.border_width_top = 1
	normal_style.border_width_right = 1
	normal_style.border_width_bottom = 1
	normal_style.border_color = Color.TRANSPARENT
	normal_style.content_margin_left = 15
	normal_style.content_margin_right = 15
	normal_style.content_margin_top = 12
	normal_style.content_margin_bottom = 12
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = bg_hover
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = bg_hover
	
	var focus_style = normal_style.duplicate()
	
	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("focus", focus_style)
	
	add_theme_color_override("font_color", text_normal)
	add_theme_color_override("font_hover_color", text_hover)
	add_theme_color_override("font_pressed_color", text_hover)
	add_theme_color_override("font_focus_color", text_normal)
	add_theme_font_size_override("font_size", 14)

func _setup_ui():
	clip_container = Control.new()
	clip_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clip_container.clip_contents = true
	clip_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(clip_container)
	
	left_border = ColorRect.new()
	left_border.color = accent_color
	left_border.size = Vector2(3, custom_minimum_size.y)
	left_border.position = Vector2(0, 0)
	left_border.anchor_top = 0.0
	left_border.anchor_bottom = 1.0
	left_border.offset_top = 0
	left_border.offset_bottom = 0
	left_border.scale = Vector2(1.0, 0.0)
	left_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_container.add_child(left_border)
	
	if icon_texture:
		icon_rect = TextureRect.new()
		icon_rect.texture = icon_texture
		icon_rect.custom_minimum_size = Vector2(18, 18)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		icon_rect.modulate = text_normal
		icon_rect.position = Vector2(50, (custom_minimum_size.y - 18) / 2)
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip_container.add_child(icon_rect)

func _setup_tweener():
	tweener = TweenerComponent.new()
	tweener.transition_type = Tween.TRANS_CUBIC
	tweener.ease_type = Tween.EASE_OUT
	add_child(tweener)

func _input(event: InputEvent):
	if not visible or not is_inside_tree():
		return
		
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		var button_rect = get_global_rect()
		var mouse_inside = button_rect.has_point(mouse_pos)
		
		if mouse_inside and not is_hovered:
			is_hovered = true
			_update_visual_state()
		elif not mouse_inside and is_hovered:
			is_hovered = false
			_update_visual_state()
			
	elif event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			var mouse_pos = get_global_mouse_position()
			var button_rect = get_global_rect()
			if button_rect.has_point(mouse_pos):
				button_pressed_custom.emit(self)

func set_button_text(new_text: String):
	button_text = new_text
	text = new_text

func set_icon(texture: Texture2D):
	icon_texture = texture
	if icon_rect:
		icon_rect.texture = texture
		icon_rect.modulate = _get_current_text_color()
	else:
		_setup_ui()

func set_active(active: bool):
	is_active = active
	_update_visual_state()

func _update_visual_state():
	if not tweener:
		return
		
	var target_bg_color: Color
	var target_border_color: Color
	var target_text_color: Color
	var target_border_scale: float
	var target_scale: Vector2
	
	if is_active:
		target_bg_color = bg_active
		target_border_color = border_active
		target_text_color = text_active
		target_border_scale = 1.0
		target_scale = scale_normal
	elif is_hovered:
		target_bg_color = bg_hover
		target_border_color = Color.TRANSPARENT
		target_text_color = text_hover
		target_border_scale = 1.0
		target_scale = scale_hover
	else:
		target_bg_color = bg_normal
		target_border_color = Color.TRANSPARENT
		target_text_color = text_normal
		target_border_scale = 0.0
		target_scale = scale_normal
	
	var duration = 0.2
	
	var current_style = get_theme_stylebox("normal") as StyleBoxFlat
	current_style.bg_color = target_bg_color
	current_style.border_color = target_border_color
	
	add_theme_color_override("font_color", target_text_color)
	add_theme_color_override("font_hover_color", target_text_color)
	add_theme_color_override("font_pressed_color", target_text_color)
	add_theme_color_override("font_focus_color", target_text_color)
	
	if icon_rect:
		tweener.play_tween(icon_rect, "modulate", [target_text_color], [duration])
	
	tweener.play_tween(self, "scale", [target_scale], [duration])
	tweener.play_tween(left_border, "scale", [Vector2(1.0, target_border_scale)], [duration])

func _get_current_text_color() -> Color:
	if is_active:
		return text_active
	elif is_hovered:
		return text_hover
	else:
		return text_normal
