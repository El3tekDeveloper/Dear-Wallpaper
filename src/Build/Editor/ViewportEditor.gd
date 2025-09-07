class_name ViewportEditor extends ScrollContainer

@export var content_grid: GridContainer

const MAX_CACHED_ITEMS = 150
const MAX_CONCURRENT_REQUESTS = 6
const MAX_DISPLAYED_ITEMS = 100

var wallpaper_sources: Array[WallpaperSource] = []
var cached_items: Array = []
var query: String = "wallpapers"
var loading: bool = false
var active_requests: int = 0
var loaded_urls: Dictionary = {}
var request_queue: Array = []
var displayed_items: Dictionary = {}
var valid_image_types = ["image/jpeg", "image/jpg", "image/png", "image/webp"]

func _ready():
	_initialize_sources()
	_load_sources()
	set_process(true)

func _initialize_sources():
	wallpaper_sources = [
		PexelsSource.new(),
		UnsplashSource.new(),
		FreepikSource.new(),
		WallhavenSource.new()
	]

func _process(_delta):
	content_grid.visible = !loading
	_process_request_queue()

func _load_sources():
	if loading: return
	loading = true
	active_requests = 0
	_cleanup_cached_items()
	loaded_urls.clear()
	_clear_items()
	
	request_queue.clear()
	for source in wallpaper_sources:
		var request_data = source.get_request_data(query)
		for url in request_data:
			_queue_request(url, source.get_headers(), func(data): _parse_source_response(source, data))

func _parse_source_response(source: WallpaperSource, data: Dictionary):
	var items = source.parse_response(data)
	for item_data in items:
		_add_item(item_data.get("id", ""), item_data.get("display_url", ""), item_data.get("full_url", ""))

func _request(url: String, headers: Array, callback: Callable):
	var req = HTTPRequest.new()
	add_child(req)
	req.timeout = 10.0
	active_requests += 1
	req.request_completed.connect(func(result, code, _headers, body):
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			callback.call(JSON.parse_string(body.get_string_from_utf8()) if body.get_string_from_utf8() else {})
		req.queue_free()
		active_requests -= 1
		if active_requests <= 0: loading = false
	)
	req.request(url, headers) if headers.size() > 0 else req.request(url)

func _add_item(id: String, display_url: String, full_url: String):
	if display_url == "" or loaded_urls.has(display_url): return
	loaded_urls[display_url] = true
	if cached_items.size() >= MAX_CACHED_ITEMS: _cleanup_oldest_items()
	
	var item = WallpaperItemRes.new()
	item.id = id
	item.display_url = display_url
	item.full_url = full_url
	cached_items.append(item)
	if displayed_items.size() < MAX_DISPLAYED_ITEMS: _create_item(item)

func _create_item(item_res: WallpaperItemRes):
	var item = WallpaperItem.new()
	content_grid.add_child(item)
	displayed_items[item_res.id] = item
	item.set_data(item_res)
	_queue_image_load(item_res, item)

func _load_image(item_res: WallpaperItemRes, target: WallpaperItem):
	if not is_instance_valid(target): return
	var req = HTTPRequest.new()
	add_child(req)
	req.timeout = 15.0
	req.request_completed.connect(func(result, code, headers, body):
		if not is_instance_valid(target) or result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.size() == 0:
			_remove_item(target, req)
			return
		
		var content_type = ""
		for header in headers:
			if header.to_lower().begins_with("content-type:"):
				content_type = header.to_lower().substr(13).strip_edges()
				break
		
		if not valid_image_types.any(func(t): return content_type.begins_with(t)):
			_remove_item(target, req)
			return
		
		var img = Image.new()
		var load_success = false
		if content_type.contains("jpeg") or content_type.contains("jpg"):
			load_success = img.load_jpg_from_buffer(body) == OK
		elif content_type.contains("png"):
			load_success = img.load_png_from_buffer(body) == OK
		elif content_type.contains("webp"):
			load_success = img.load_webp_from_buffer(body) == OK
		else:
			load_success = (img.load_jpg_from_buffer(body) == OK or img.load_png_from_buffer(body) == OK or img.load_webp_from_buffer(body) == OK)
		
		if not load_success or img.get_width() <= img.get_height():
			_remove_item(target, req)
			return
			
		item_res.image = img
		if is_instance_valid(target): target.set_data(item_res)
		req.queue_free()
	)
	req.request(item_res.display_url)

func _remove_item(target: WallpaperItem, req: HTTPRequest):
	if is_instance_valid(target):
		for key in displayed_items:
			if displayed_items[key] == target:
				displayed_items.erase(key)
				break
		content_grid.remove_child(target)
		target.queue_free()
	if is_instance_valid(req): req.queue_free()

func _clear_items():
	if not is_instance_valid(content_grid): return
	for item in content_grid.get_children():
		if is_instance_valid(item): item.queue_free()
	displayed_items.clear()

func update_all_items():
	var new_items = cached_items.filter(func(item): return not displayed_items.has(item.id))
	var items_to_add = min(new_items.size(), MAX_DISPLAYED_ITEMS - displayed_items.size())
	for i in range(items_to_add):
		var item_res = new_items[i]
		if item_res.has_image():
			var item = WallpaperItem.new()
			content_grid.add_child(item)
			displayed_items[item_res.id] = item
			item.set_data(item_res)
		else:
			_create_item(item_res)

func retry_failed_requests():
	_load_sources()

func _cleanup_cached_items():
	while cached_items.size() > MAX_CACHED_ITEMS:
		var item = cached_items.pop_front()
		if item.image: item.image = null

func _cleanup_oldest_items():
	var items_to_remove = int(MAX_CACHED_ITEMS * 0.2)
	for i in range(min(items_to_remove, cached_items.size())):
		var item = cached_items.pop_front()
		if item.image: item.image = null

func _queue_request(url: String, headers: Array, callback: Callable):
	request_queue.append([url, headers, callback])

func _process_request_queue():
	if active_requests >= MAX_CONCURRENT_REQUESTS or request_queue.is_empty(): return
	var req_data = request_queue.pop_front()
	_request(req_data[0], req_data[1], req_data[2])

func _queue_image_load(item_res: WallpaperItemRes, target: WallpaperItem):
	_load_image(item_res, target)

func add_wallpaper_source(source: WallpaperSource):
	if source not in wallpaper_sources:
		wallpaper_sources.append(source)
