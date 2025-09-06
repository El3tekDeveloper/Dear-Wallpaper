class_name ViewportEditor extends ScrollContainer

@export var content_grid: GridContainer

const PEXELS_API_KEY = "OkOdpPsc8moLsdTBqQTGV7NoRyCvrDtVH80QE14QPaYVGS6A2qlGGKar"
const UNSPLASH_API_KEY = "V_VH42sqX29wh4D2hA9d2N0p5se0xmjNZ1N3K-KJAMg"

var cached_items: Array = []
var query: String = "wallpapers"
var loading: bool = false

func _ready():
	_load_all_sources()
	set_process(true)

func _process(delta):
	content_grid.visible = !loading

func _load_all_sources():
	if loading: return
	loading = true
	cached_items.clear()
	clear_all_items()
	if query == "": query = "wallpapers"
	
	var pexels_page = randi_range(1, 100)
	var pexels_url = "https://api.pexels.com/v1/search?query=" + query + "&per_page=" + str(pexels_page)
	var pexels_req = HTTPRequest.new()
	add_child(pexels_req)
	pexels_req.request_completed.connect(_on_request_completed_pexels)
	var headers = ["Authorization: " + PEXELS_API_KEY]
	pexels_req.request(pexels_url, headers)
	
	var unsplash_url = "https://api.unsplash.com/search/photos?query=" + query + "&per_page=80&client_id=" + UNSPLASH_API_KEY
	var unsplash_req = HTTPRequest.new()
	add_child(unsplash_req)
	unsplash_req.request_completed.connect(_on_request_completed_unsplash)
	unsplash_req.request(unsplash_url)

func _on_request_completed_pexels(result: int, response_code: int, headers: Array, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200: loading = false; return
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK: loading = false; return
	
	var results: Array = json.data.get("photos", [])
	for photo in results:
		var width = photo.get("width", 0)
		var height = photo.get("height", 0)
		
		var display_url = photo.get("src", {}).get("large", "")
		var full_url = photo.get("src", {}).get("original", "")
		
		var item_res := WallpaperItemRes.new()
		var wallpaper_item = WallpaperItem.new()
		
		if width <= height: continue
		item_res.id = str(photo.get("id", 0))
		item_res.display_url = display_url
		item_res.full_url = full_url
		cached_items.append(item_res)
		
		content_grid.add_child(wallpaper_item)
		wallpaper_item.set_data(item_res)
		_load_image_for_item(item_res, wallpaper_item)
	loading = false

func _on_request_completed_unsplash(result: int, response_code: int, headers: Array, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200: loading = false; return
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK: loading = false; return
	
	var results: Array = json.data.get("results", [])
	for photo in results:
		var width = photo.get("width", 0)
		var height = photo.get("height", 0)
		
		var display_url = photo.get("urls", {}).get("regular", "")
		var full_url = photo.get("urls", {}).get("full", "")
		
		var item_res := WallpaperItemRes.new()
		var wallpaper_item = WallpaperItem.new()
		
		if width <= height: continue
		item_res.id = str(photo.get("id", 0))
		item_res.display_url = display_url
		item_res.full_url = full_url
		cached_items.append(item_res)
		
		content_grid.add_child(wallpaper_item)
		wallpaper_item.set_data(item_res)
		_load_image_for_item(item_res, wallpaper_item)
	loading = false

func _load_image_for_item(item_res: WallpaperItemRes, target_item: WallpaperItem):
	var req = HTTPRequest.new()
	add_child(req)
	req.request_completed.connect(func(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
		if result != HTTPRequest.RESULT_SUCCESS or response_code != 200: return
		var img = Image.new()
		var err = img.load_jpg_from_buffer(body)
		if err != OK:
			err = img.load_png_from_buffer(body)
			if err != OK: return
		item_res.image = img
		target_item.set_data(item_res)
		req.queue_free()
	)
	req.request(item_res.display_url)

func clear_all_items():
	for item in content_grid.get_children():
		item.queue_free()

func update_all_items():
	clear_all_items()
	for item_res in cached_items:
		var wallpaper_item = WallpaperItem.new()
		content_grid.add_child(wallpaper_item)
		wallpaper_item.set_data(item_res)
		if not item_res.has_image():
			_load_image_for_item(item_res, wallpaper_item)
