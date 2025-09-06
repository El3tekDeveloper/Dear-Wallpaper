extends Node

#@onready var next_button: Button = $VBoxContainer/NextButton
#@onready var search_bar: LineEdit = $VBoxContainer/SearchBar
#@onready var resolution_option: OptionButton = $VBoxContainer/ResolutionOption

#@onready var image_display: TextureRect = $VBoxContainer/WallpaperPanel/PanelContainer/ImageDisplay
#@onready var download_button: TextureButton = $VBoxContainer/WallpaperPanel/Panel/MarginContainer/HBoxContainer/DownloadButton
#@onready var image_titel: Label = $VBoxContainer/WallpaperPanel/Panel/MarginContainer/HBoxContainer/Title

@onready var image_display: TextureRect = $PanelContainer/ImageDisplay
@onready var download_button: TextureButton = $Panel/MarginContainer/HBoxContainer/DownloadButton
@onready var image_titel: Label = $Panel/MarginContainer/HBoxContainer/Title

var http: HTTPRequest
var image_request: HTTPRequest
var current_image: Image = null
var current_image_name: String = "wallpaper"
var full_image_url: String = ""
const UNSPLASH_KEY = "V_VH42sqX29wh4D2hA9d2N0p5se0xmjNZ1N3K-KJAMg"
var save_folder: String = "C:/Users/youel/Downloads"

func _ready():
	randomize()
	http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", Callable(self, "_on_request_completed"))
	image_request = HTTPRequest.new()
	add_child(image_request)
	image_request.connect("request_completed", Callable(self, "_on_request_completed_image"))
	#next_button.pressed.connect(_load_next_image)
	download_button.pressed.connect(_save_current_image)
	#resolution_option.add_item("All")
	#resolution_option.add_item("FullHD (1920x1080)")
	#resolution_option.add_item("4K (3840x2160)")
	#resolution_option.select(0)
	_load_next_image()

func _load_next_image():
	#var query = search_bar.text.strip_edges()
	#if query == "":
		#query = "wallpapers"
	var query = "wallpapers"
	var url = "https://api.unsplash.com/search/photos?query=" + query + "&orientation=landscape&per_page=30&client_id=" + UNSPLASH_KEY
	http.request(url)

func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var text = body.get_string_from_utf8()
	var json = JSON.new()
	if json.parse(text) != OK:
		return
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return
	var results = data.get("results", [])
	if results.size() == 0:
		return
	var random_photo = results[randi() % results.size()]
	if typeof(random_photo) != TYPE_DICTIONARY:
		return
	var urls = random_photo.get("urls", {})
	if typeof(urls) != TYPE_DICTIONARY:
		return
	#var selected_res = resolution_option.get_item_text(resolution_option.selected)
	var display_url = ""
	#match selected_res:
		#"4K (3840x2160)":
			#display_url = urls.get("raw", urls.get("full", urls.get("regular", "")))
			#full_image_url = display_url
		#"FullHD (1920x1080)":
			#display_url = urls.get("full", urls.get("regular", urls.get("small", "")))
			#full_image_url = urls.get("raw", display_url)
		#_:
			#display_url = urls.get("regular", urls.get("small", ""))
			#full_image_url = urls.get("full", display_url)
	display_url = urls.get("regular", urls.get("small", ""))
	full_image_url = urls.get("full", display_url)
	
	current_image_name = random_photo.get("id", "wallpaper")
	image_request.set_meta("full_image", false)
	image_request.request(display_url)

func _on_request_completed_image(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	if body.size() == 0:
		return
	var img = Image.new()
	var load_result = OK
	if body.size() >= 8:
		if body[0] == 0x89 and body[1] == 0x50 and body[2] == 0x4E and body[3] == 0x47:
			load_result = img.load_png_from_buffer(body)
		elif body[0] == 0xFF and body[1] == 0xD8:
			load_result = img.load_jpg_from_buffer(body)
		else:
			load_result = img.load_png_from_buffer(body)
			if load_result != OK:
				load_result = img.load_jpg_from_buffer(body)
	if load_result != OK:
		_load_next_image()
		return
	current_image = img
	image_display.texture = ImageTexture.create_from_image(img)
	var format = img.get_format()
	var extension = ".png" if format in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAF] else ".jpg"
	image_titel.text = current_image_name + extension

func _save_current_image():
	if full_image_url == "" or current_image_name == "":
		return
	var http_save = HTTPRequest.new()
	add_child(http_save)
	http_save.connect("request_completed", Callable(self, "_on_save_image_completed"))
	http_save.request(full_image_url)

func _on_save_image_completed(result: int, response_code: int, headers: Array, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var img = Image.new()
	var load_result = OK
	if body.size() >= 8:
		if body[0] == 0x89 and body[1] == 0x50 and body[2] == 0x4E and body[3] == 0x47:
			load_result = img.load_png_from_buffer(body)
		elif body[0] == 0xFF and body[1] == 0xD8:
			load_result = img.load_jpg_from_buffer(body)
		else:
			load_result = img.load_png_from_buffer(body)
			if load_result != OK:
				load_result = img.load_jpg_from_buffer(body)
	if load_result != OK:
		return
	var format = img.get_format()
	var extension = ".png" if format in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAF] else ".jpg"
	var full_path = save_folder + "/" + current_image_name + extension
	if extension == ".png":
		img.save_png(full_path)
	else:
		img.save_jpg(full_path, 100)
	
	var wallpaper = WallpaperRes.new()
	wallpaper.ChangeWallpaper(full_path)
