extends Node

var style_accent: StyleBox = preload("res://UI&UX/StyleAccent.tres")

var bold_label_settings: LabelSettings = preload("res://UI&UX/BoldLabel.tres")
var label_settings: LabelSettings = preload("res://UI&UX/Label.tres")

func creat_panel(minimum_size: Vector2, style: StyleBox, parent: Node = null) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = minimum_size
	panel.add_theme_stylebox_override("panel", style)
	
	parent.add_child(panel)
	return panel

func creat_gradient_panel(minimum_size: Vector2, style: StyleBox, parent: Node = null, shader_settings: Dictionary = {}) -> Panel:
	var panel = creat_panel(minimum_size, style, parent)
	var mat := ShaderMaterial.new()
	var shader: Shader = preload("res://Shaders/Gradient.gdshader").duplicate()
	mat.shader = shader
	
	for key in shader_settings.keys():
		mat.set_shader_parameter(key, shader_settings[key])
	
	panel.material = mat
	return panel

func create_margin_container(margin: int = 10, parent: Node = null) -> MarginContainer:
	var container = MarginContainer.new()
	container.add_theme_constant_override("margin_top", margin)
	container.add_theme_constant_override("margin_left", margin)
	container.add_theme_constant_override("margin_bottom", margin)
	container.add_theme_constant_override("margin_right", margin)
	
	parent.add_child(container)
	return container

func create_box_container(separation_scale: int = 16, vertical: bool = false, parent: Node = null) -> BoxContainer:
	var box_container = BoxContainer.new()
	box_container.vertical = vertical
	
	parent.add_child(box_container)
	return box_container

func create_label(text: String, font_size: int, settings: LabelSettings, parent: Node = null) -> Label:
	var label = Label.new()
	label.text = text
	settings = settings.duplicate()
	settings.font_size = font_size
	parent.add_child(label)
	return label

func create_h_separator(space: float, parent: Node = null) -> HSeparator:
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(0, space)
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

func create_line_edit(placeholder: String, icon: Texture2D,  perent: Node = null) -> CustomLineEdit:
	var edit_line = CustomLineEdit.new()
	edit_line._set_placeholder(placeholder)
	edit_line.set_trailing_icon(icon)
	perent.add_child(edit_line)
	return edit_line

func describe(what: Object, description: Dictionary) -> void:
	for d: String in description:
		what.set(d, description.get(d))

func create_custom_style(color: Color = Color(1, 1, 1, 1), border_color: Color = Color(0, 0, 0, 1), border_width: int = 0, corner_radius: int = 0) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	return style
