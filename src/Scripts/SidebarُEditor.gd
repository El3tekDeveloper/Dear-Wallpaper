extends Control

@export var list: BoxContainer

func _ready() -> void:
	app_titel()
	set_sidebar_tree()

func set_sidebar_tree() -> void:
	InterfaceServer.describe(InterfaceServer.create_label("Library", 15, InterfaceServer.bold_label_settings, list)
		, {self_modulate = Color8(255, 255, 255, 180)})
	
	var browse_button = InterfaceServer.create_sidebar_button("Browse", preload("res://Icons/search-engine.png"), list)
	var favorites_button = InterfaceServer.create_sidebar_button("Favorites", preload("res://Icons/favorite.png"), list)

func app_titel() -> void:
	var panel = InterfaceServer.creat_panel(Vector2(0, 80), InterfaceServer.style_accent, list)
	var marage = InterfaceServer.create_margin_container(15, panel)
	var hbox = InterfaceServer.create_box_container(18, false, marage)
	var icon = InterfaceServer.creat_gradient_panel(
		Vector2(45, 45),
		InterfaceServer.create_custom_style(Color.WHITE, Color.WHEAT, 0, 10), 
		hbox, 
		{
			"direction": Vector2(30, 30), 
			"start_color": Color8(0, 150, 255, 255),
			"end_color": Color8(0, 212, 255, 255)
		}
	)
	var vbox = InterfaceServer.create_box_container(10, true, hbox)
	InterfaceServer.create_label("Wallpaper Engine", 19, InterfaceServer.bold_label_settings, vbox)
	InterfaceServer.describe(InterfaceServer.create_label("-virsion 0.1", 13, InterfaceServer.label_settings, vbox), {self_modulate = Color8(255, 255, 255, 180)})
	InterfaceServer.describe(InterfaceServer.create_h_separator(0, list), {self_modulate = Color8(0, 0, 0, 0)})
