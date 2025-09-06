extends PanelContainer

@export var list: HBoxContainer
@export var viweport: ViewportEditor

func _ready() -> void:
	var search_bar = InterfaceServer.create_line_edit("Search Wallpapers... ", preload("res://Assets/Icons/magnifying-glass.png"), 
		list, {size_flags_horizontal = SIZE_EXPAND_FILL})
	InterfaceServer.create_v_separator(10, list)
	
	search_bar.text_submitted.connect(func(_new_text):
		viweport.query = search_bar.text.strip_edges()
		viweport.cached_items.clear()
		viweport.clear_all_items()
		viweport._load_all_sources()
	)
	
	var add_wallpaper_btn = InterfaceServer.create_button(Vector2(100, 32), false, "Add Wallpaper", null, list)
	var apply_btn = InterfaceServer.create_button(Vector2(100, 32), true, "Apply", null, list)
