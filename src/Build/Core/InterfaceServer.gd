extends Node

var style_accent: StyleBox = preload("res://UI&UX/StyleAccent.tres")

var bold_label_settings: LabelSettings = preload("res://UI&UX/BoldLabel.tres")
var label_settings: LabelSettings = preload("res://UI&UX/Label.tres")

var tweener: TweenerComponent

func _ready() -> void:
	tweener = TweenerComponent.new()
	add_child(tweener)

func create_panel(minimum_size: Vector2, style: StyleBox, parent: Node = null, more: Dictionary = {}) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = minimum_size
	panel.add_theme_stylebox_override("panel", style)
	describe(panel, more)
	parent.add_child(panel)
	return panel

func create_container_panel(minimum_size: Vector2, style: StyleBox, parent: Node = null, more: Dictionary = {}) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = minimum_size
	panel.add_theme_stylebox_override("panel", style)
	describe(panel, more)
	parent.add_child(panel)
	return panel

func create_shader_panel(minimum_size: Vector2, style: StyleBox, shader: Shader, parent: Node = null, shader_settings: Dictionary = {}) -> Panel:
	var panel = create_panel(minimum_size, style, parent)
	var mat := ShaderMaterial.new()
	shader = shader.duplicate(); mat.shader = shader
	
	for key in shader_settings.keys():
		mat.set_shader_parameter(key, shader_settings[key])
	
	panel.material = mat
	return panel

func create_margin_container(margin: int = 10, parent: Node = null, more: Dictionary = {}) -> MarginContainer:
	var container = MarginContainer.new()
	container.add_theme_constant_override("margin_top", margin)
	container.add_theme_constant_override("margin_left", margin)
	container.add_theme_constant_override("margin_bottom", margin)
	container.add_theme_constant_override("margin_right", margin)
	describe(container, more)
	parent.add_child(container)
	return container

func create_box_container(separation_scale: int = 16, vertical: bool = false, parent: Node = null, more: Dictionary = {}) -> BoxContainer:
	var box_container = BoxContainer.new()
	box_container.add_theme_constant_override("separation", separation_scale)
	box_container.vertical = vertical
	describe(box_container, more)
	parent.add_child(box_container)
	return box_container

func create_label(text: String, font_size: int, settings: LabelSettings, parent: Node = null, more: Dictionary = {}) -> Label:
	var label = Label.new()
	label.text = text
	settings = settings.duplicate()
	settings.font_size = font_size
	label.label_settings = settings
	describe(label, more)
	parent.add_child(label)
	return label

func create_h_separator(space: float, parent: Node = null, more: Dictionary = {}) -> HSeparator:
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(0, space)
	describe(separator, more)
	parent.add_child(separator)
	return separator

func create_v_separator(space: float, parent: Node = null) -> VSeparator:
	var separator = VSeparator.new()
	separator.custom_minimum_size = Vector2(space, 0)
	parent.add_child(separator)
	return separator

func create_sidebar_button(text: String, icon: Texture2D, perent: Node = null) -> SelectButton:
	var button = SelectButton.new()
	button.set_button_text(text)
	button.set_icon(icon)
	
	perent.add_child(button)
	return button

func create_line_edit(placeholder: String, icon: Texture2D,  perent: Node = null, more: Dictionary = {}) -> CustomLineEdit:
	var edit_line = CustomLineEdit.new()
	edit_line._set_placeholder(placeholder)
	edit_line.set_trailing_icon(icon)
	describe(edit_line, more)
	perent.add_child(edit_line)
	return edit_line

func create_button(minimum_size: Vector2, accent: bool, text: String, icon: Texture2D, perent: Node = null, more: Dictionary = {}) -> CustomButton:
	var button; if accent: button = CustomButton.create_accent_button(text, icon)
	else: button = CustomButton.create_normal_button(text, icon)
	describe(button, more)
	perent.add_child(button)
	return button

func create_texture_button(texture: Texture2D, perent: Node = null, more: Dictionary = {}, scaleup: bool = false) -> TextureButton:
	var button = TextureButton.new()
	button.texture_normal = texture
	
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	button.mouse_entered.connect(func(): 
		button.modulate = Color(0.0, 0.588, 1.0, 1.0)
		if scaleup: tweener.play_tween(button, "scale", [Vector2(1.1, 1.1)], [0.2])
	)
	button.mouse_exited.connect(func(): 
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if scaleup: tweener.play_tween(button, "scale", [Vector2(1.0, 1.0)], [0.2])
	)
	
	describe(button, more)
	perent.add_child(button)
	return button

func create_color_rect(color: Color, perent: Node = null, more: Dictionary = {}) -> ColorRect:
	var color_rect = ColorRect.new()
	color_rect.color = color
	perent.add_child(color_rect)
	describe(color_rect, more)
	return color_rect

func create_texture_rect(minimum_size: Vector2, texture: Texture, perent: Node = null, more: Dictionary = {}) -> TextureRect:
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = minimum_size
	texture_rect.texture = texture
	describe(texture_rect, more)
	
	perent.add_child(texture_rect)
	return texture_rect

func create_custom_style(color: Color = Color(1, 1, 1, 1), border_color: Color = Color(0, 0, 0, 1), border_width: int = 0, corner_radius: int = 0, more: Dictionary = {}) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	describe(style, more)
	return style

func describe(target: Object, description: Dictionary) -> void:
	for i: String in description:
		target.set(i, description.get(i))

func add_shader(target: Object, shader: Shader, shader_settings: Dictionary = {}) -> void:
	var mat := ShaderMaterial.new()
	shader = shader.duplicate(); mat.shader = shader
	
	for key in shader_settings.keys():
		mat.set_shader_parameter(key, shader_settings[key])
	target.material = mat
