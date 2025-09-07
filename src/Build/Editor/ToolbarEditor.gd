extends PanelContainer

@export var list: HBoxContainer
@export var viewport: ViewportEditor

func _ready() -> void:
	var search_bar = InterfaceServer.create_line_edit("Search Wallpapers... ", preload("res://Assets/Icons/magnifying-glass.png"), 
		list, {size_flags_horizontal = SIZE_EXPAND_FILL})
	InterfaceServer.create_v_separator(10, list)
	
	search_bar.text_submitted.connect(func(_new_text):
		viewport.query = search_bar.text.strip_edges()
		viewport.cached_items.clear()
		viewport._clear_items()
		viewport._load_sources())
	
	var add_wallpaper_btn = InterfaceServer.create_button(Vector2(100, 32), false, "Add Wallpaper", null, list)
	var apply_btn = InterfaceServer.create_button(Vector2(100, 32), true, "Apply", null, list)
