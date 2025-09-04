extends PanelContainer

@export var list: HBoxContainer

func _ready() -> void:
	var search_bar = InterfaceServer.create_line_edit("Search Wallpapers... ", preload("res://Icons/magnifying-glass.png"), list)
	search_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	InterfaceServer.create_v_separator(10, list)
	
	var add_wallpaper_btn = CustomButton.create_normal_button("Add Wallpaper")
	var apply_btn = CustomButton.create_accent_button("Apply")
	
	list.add_child(add_wallpaper_btn)
	list.add_child(apply_btn)
