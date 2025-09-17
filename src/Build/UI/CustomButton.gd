@tool
extends Button
class_name CustomButton

enum ButtonStyle { NORMAL, ACCENT }

@export var button_style: ButtonStyle = ButtonStyle.NORMAL : set = set_button_style
@export var icon_texture: Texture2D : set = set_icon_texture
@export var glow_enabled: bool = true : set = set_glow_enabled
@export var animate_hover: bool = true : set = set_animate_hover

var colors = {
	"normal_bg": Color(0.188, 0.212, 0.239, 0.3),
	"normal_border": Color(0.188, 0.212, 0.239, 0.8),
	"normal_text": Color(0.788, 0.816, 0.851),
	"hover_bg": Color(0.188, 0.212, 0.239, 0.6),
	"hover_border": Color8(48, 54, 61, 0.8),
	"accent_bg": Color(0.0, 0.588, 1.0),
	"accent_border": Color(0.0, 0.588, 1.0),
	"accent_text": Color(1.0, 1.0, 1.0),
	"accent_hover_bg": Color(0.0, 0.525, 0.902),
	"accent_hover_border": Color(0.0, 0.525, 0.902),
}

var icon_node: TextureRect
var original_position: Vector2
var tween: Tween

func _init():
	custom_minimum_size = Vector2(100, 32)
	clip_contents = false

func _ready():
	if not is_inside_tree():
		await tree_entered
	
	apply_style()
	setup_icon()
	
	for signal_name in ["mouse_entered", "mouse_exited", "button_down", "button_up", "resized"]:
		get(signal_name).connect(get("_" + signal_name))

func create_style_boxes():
	var is_accent = button_style == ButtonStyle.ACCENT
	var styles = ["normal", "hover", "pressed", "focus"]
	var bg_colors = [
		colors.accent_bg if is_accent else colors.normal_bg,
		colors.accent_hover_bg if is_accent else colors.hover_bg,
		(colors.accent_hover_bg if is_accent else colors.hover_bg).darkened(0.1),
		colors.accent_hover_bg if is_accent else colors.hover_bg
	]
	var border_colors = [
		colors.accent_border if is_accent else colors.normal_border,
		colors.accent_hover_border if is_accent else colors.hover_border,
		colors.accent_hover_border if is_accent else colors.hover_border,
		colors.accent_hover_border if is_accent else colors.hover_border
	]
	
	for i in range(4):
		var style_box = StyleBoxFlat.new()
		setup_style_box(style_box, bg_colors[i], border_colors[i])
		add_theme_stylebox_override(styles[i], style_box)

func setup_style_box(style_box: StyleBoxFlat, bg_color: Color, border_color: Color):
	style_box.bg_color = bg_color
	style_box.set_border_width_all(1)
	style_box.border_color = border_color
	style_box.set_corner_radius_all(6)
	style_box.set_content_margin_all(16)
	style_box.content_margin_top = 8
	style_box.content_margin_bottom = 8
	
	if button_style == ButtonStyle.ACCENT and glow_enabled:
		style_box.shadow_color = Color(0.0, 0.588, 1.0, 0.3)
		style_box.shadow_size = 8
		style_box.shadow_offset = Vector2.ZERO

func setup_icon():
	if not icon_texture:
		return
		
	if icon_node:
		icon_node.queue_free()
		
	icon_node = TextureRect.new()
	icon_node.texture = icon_texture
	icon_node.custom_minimum_size = Vector2(14, 14)
	icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon_node)
	
	_resized()
	add_theme_constant_override("hseparation", 6)

func apply_style():
	create_style_boxes()
	
	var text_color = colors.accent_text if button_style == ButtonStyle.ACCENT else colors.normal_text
	for color_type in ["font_color", "font_hover_color", "font_pressed_color"]:
		add_theme_color_override(color_type, text_color)
	
	add_theme_constant_override("font_size", 13)

func _mouse_entered():
	if animate_hover:
		animate_hover_effect(true)

func _mouse_exited():
	if animate_hover:
		animate_hover_effect(false)

func _button_down():
	if animate_hover:
		animate_press_effect(true)

func _button_up():
	if animate_hover:
		animate_press_effect(false)

func _resized():
	if icon_node:
		icon_node.position = Vector2(12, (size.y - 14) / 2)

func animate_hover_effect(hover_in: bool):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	var target_scale = Vector2(1.02, 1.02) if hover_in else Vector2.ONE
	var target_y_offset = -2 if hover_in else 0
	
	tween.tween_property(self, "scale", target_scale, 0.2)
	tween.tween_property(self, "position:y", original_position.y + target_y_offset, 0.2)
	
	if icon_node and button_style == ButtonStyle.ACCENT:
		var target_modulate = Color.WHITE if hover_in else Color(0.9, 0.9, 0.9)
		tween.tween_property(icon_node, "modulate", target_modulate, 0.2)

func animate_press_effect(pressed: bool):
	if not animate_hover or not tween:
		return
		
	tween.kill()
	tween = create_tween()
	var target_scale = Vector2(0.98, 0.98) if pressed else Vector2(1.02, 1.02)
	tween.tween_property(self, "scale", target_scale, 0.1)

func set_button_style(value: ButtonStyle):
	button_style = value
	if is_inside_tree():
		apply_style()

func set_icon_texture(value: Texture2D):
	icon_texture = value
	if is_inside_tree():
		setup_icon()

func set_glow_enabled(value: bool):
	glow_enabled = value
	if is_inside_tree():
		apply_style()

func set_animate_hover(value: bool):
	animate_hover = value

func _enter_tree():
	await get_tree().process_frame
	original_position = position

func setup_as_normal_button(button_text: String, icon: Texture2D = null):
	_setup_button(button_text, ButtonStyle.NORMAL, icon)

func setup_as_accent_button(button_text: String, icon: Texture2D = null):
	_setup_button(button_text, ButtonStyle.ACCENT, icon)

func _setup_button(button_text: String, style: ButtonStyle, icon: Texture2D):
	text = button_text
	button_style = style
	icon_texture = icon
	if is_inside_tree():
		apply_style()
		setup_icon()
