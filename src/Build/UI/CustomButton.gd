@tool
extends Button
class_name CustomButton

enum ButtonStyle {
	NORMAL,    
	ACCENT     
}

@export var button_style: ButtonStyle = ButtonStyle.NORMAL : set = set_button_style
@export var icon_texture: Texture2D : set = set_icon_texture
@export var glow_enabled: bool = true : set = set_glow_enabled
@export var animate_on_hover: bool = true : set = set_animate_on_hover

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
	
	setup_button()
	setup_icon()
	setup_signals()
	
	apply_style()

func setup_button():
	create_style_boxes()

func setup_icon():
	if icon_texture:
		if icon_node:
			icon_node.queue_free()
		icon_node = TextureRect.new()
		icon_node.texture = icon_texture
		icon_node.custom_minimum_size = Vector2(14, 14)
		icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon_node)
		
		icon_node.position = Vector2(12, (size.y - 14) / 2)
		add_theme_constant_override("hseparation", 6)

func setup_signals():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	resized.connect(_on_resized)

func create_style_boxes():
	var normal_style = StyleBoxFlat.new()
	var hover_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	
	setup_style_box(normal_style, get_normal_bg_color(), get_normal_border_color())
	setup_style_box(hover_style, get_hover_bg_color(), get_hover_border_color())
	setup_style_box(pressed_style, get_hover_bg_color(), get_hover_border_color())
	pressed_style.bg_color = pressed_style.bg_color.darkened(0.1)
	
	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("focus", hover_style)

func setup_style_box(style_box: StyleBoxFlat, bg_color: Color, border_color: Color):
	style_box.bg_color = bg_color
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = border_color
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	style_box.content_margin_left = 16
	style_box.content_margin_right = 16
	style_box.content_margin_top = 8
	style_box.content_margin_bottom = 8
	
	if button_style == ButtonStyle.ACCENT and glow_enabled:
		style_box.shadow_color = Color(0.0, 0.588, 1.0, 0.3) 
		style_box.shadow_size = 8
		style_box.shadow_offset = Vector2.ZERO

func apply_style():
	create_style_boxes()
	
	var text_color = get_text_color()
	add_theme_color_override("font_color", text_color)
	add_theme_color_override("font_hover_color", text_color)
	add_theme_color_override("font_pressed_color", text_color)
	
	add_theme_constant_override("font_size", 13)

func get_normal_bg_color() -> Color:
	return colors.accent_bg if button_style == ButtonStyle.ACCENT else colors.normal_bg

func get_normal_border_color() -> Color:
	return colors.accent_border if button_style == ButtonStyle.ACCENT else colors.normal_border

func get_hover_bg_color() -> Color:
	return colors.accent_hover_bg if button_style == ButtonStyle.ACCENT else colors.hover_bg

func get_hover_border_color() -> Color:
	return colors.accent_hover_border if button_style == ButtonStyle.ACCENT else colors.hover_border

func get_text_color() -> Color:
	return colors.accent_text if button_style == ButtonStyle.ACCENT else colors.normal_text

func _on_mouse_entered():
	if animate_on_hover:
		animate_hover_effect(true)

func _on_mouse_exited():
	if animate_on_hover:
		animate_hover_effect(false)

func _on_button_down():
	if animate_on_hover:
		animate_press_effect(true)

func _on_button_up():
	if animate_on_hover:
		animate_press_effect(false)

func _on_resized():
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
	if not animate_on_hover:
		return
		
	if tween:
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

func set_animate_on_hover(value: bool):
	animate_on_hover = value

func _enter_tree():
	await get_tree().process_frame
	original_position = position

func setup_as_normal_button(button_text: String, icon: Texture2D = null):
	text = button_text
	button_style = ButtonStyle.NORMAL
	icon_texture = icon
	if is_inside_tree():
		apply_style()
		setup_icon()

func setup_as_accent_button(button_text: String, icon: Texture2D = null):
	text = button_text
	button_style = ButtonStyle.ACCENT
	icon_texture = icon
	if is_inside_tree():
		apply_style()
		setup_icon()

static func create_normal_button(button_text: String, icon: Texture2D = null) -> CustomButton:
	var button = CustomButton.new()
	button.setup_as_normal_button(button_text, icon)
	return button

static func create_accent_button(button_text: String, icon: Texture2D = null) -> CustomButton:
	var button = CustomButton.new()
	button.setup_as_accent_button(button_text, icon)
	return button
