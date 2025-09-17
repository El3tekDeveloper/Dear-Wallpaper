extends Control

@export var list: BoxContainer
func _ready() -> void:
	app_titel()
	set_sidebar_tree()

func set_sidebar_tree() -> void:
	InterfaceServer.create_h_separator(0, list)
	InterfaceServer.create_label("Library", 15, InterfaceServer.bold_label_settings, list, {self_modulate = Color8(255, 255, 255, 180)})
	
	var browse_button = InterfaceServer.create_sidebar_button("Browse", preload("res://Assets/Icons/search-engine.png"), list)
	var favorites_button = InterfaceServer.create_sidebar_button("Favorites", preload("res://Assets/Icons/favorite.png"), list)
	var recently_used_button = InterfaceServer.create_sidebar_button("     Recently Used", preload("res://Assets/Icons/recent.png"), list)
	var collections_button = InterfaceServer.create_sidebar_button("Collections", preload("res://Assets/Icons/images_icon.png"), list)
	
	InterfaceServer.create_h_separator(0, list)
	InterfaceServer.create_label("Categories", 15, InterfaceServer.bold_label_settings, list, {self_modulate = Color8(255, 255, 255, 180)})
	
	var video_wallpapers_button = InterfaceServer.create_sidebar_button("      Video Wallpapers", preload("res://Assets/Icons/clapperboard.png"), list)
	var web_wallpapers_button = InterfaceServer.create_sidebar_button("     Web Wallpapers", preload("res://Assets/Icons/html.png"), list)
	var static_images_button = InterfaceServer.create_sidebar_button("Static Images", preload("res://Assets/Icons/insert-picture-icon.png"), list)
	
	InterfaceServer.create_h_separator(0, list)
	InterfaceServer.create_label("System", 15, InterfaceServer.bold_label_settings, list, {self_modulate = Color8(255, 255, 255, 180)})
	
	var settings_button = InterfaceServer.create_sidebar_button("Settings", preload("res://Assets/Icons/settings.png"), list)

func app_titel() -> void:
	var panel = InterfaceServer.create_panel(Vector2(0, 80), InterfaceServer.style_accent, list)
	var marage = InterfaceServer.create_margin_container(15, panel)
	var hbox = InterfaceServer.create_box_container(10, false, marage)
	
	var icon = InterfaceServer.create_panel(Vector2(50, 50), InterfaceServer.create_custom_style(Color.WHITE, Color.WHEAT, 0, 10), hbox, {size_flags_horizontal = false, size_flags_vertical = false})
	InterfaceServer.add_shader(icon, preload("res://Shaders/Gradient.gdshader"), 
		{direction = Vector2(30, 30), 
		start_color = Color8(0, 150, 255, 255), end_color = Color8(0, 212, 255, 255)})
	var icon_marage = InterfaceServer.create_margin_container(5, icon)
	var logo = InterfaceServer.create_texture_rect(Vector2(40, 40), preload("res://Logo.svg"), icon_marage, {
		expand_mode = TextureRect.EXPAND_IGNORE_SIZE,
		stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED,
		anchor_left = 0.5, anchor_right = 0.5, anchor_top = 0.5, anchor_bottom = 0.5,
		offset_left = -22.5, offset_right = 22.5, offset_top = -22.5, offset_bottom = 22.5})
	
	var vbox = InterfaceServer.create_box_container(5, true, hbox)
	InterfaceServer.create_label("Dear Wallpaper", 19, InterfaceServer.bold_label_settings, vbox)
	InterfaceServer.create_label("-virsion 0.1", 14, InterfaceServer.label_settings, vbox, {self_modulate = Color8(255, 255, 255, 180)})
