class_name WallhavenSource extends WallpaperSource

func _init():
	super("", "https://wallhaven.cc/api/v1/search", "wallhaven")

func get_request_data(query: String) -> Array:
	var q = query.uri_encode() if query != "" else "wallpapers".uri_encode()
	return [base_url + "?q=" + q + "&categories=111&purity=100&sorting=random&per_page=24"]

func get_headers() -> Array:
	return []

func parse_response(data: Dictionary) -> Array:
	var items = []
	for photo in data.get("data", []):
		var path = photo.get("path", "")
		var resolution = photo.get("resolution", "")
		if resolution == "" or _is_landscape(resolution):
			items.append({
				"id": str(photo.get("id", "")),
				"display_url": path,
				"full_url": path
			})
	return items

func _is_landscape(resolution: String) -> bool:
	var parts = resolution.split("x")
	return parts.size() == 2 and parts[0].to_int() > parts[1].to_int()
