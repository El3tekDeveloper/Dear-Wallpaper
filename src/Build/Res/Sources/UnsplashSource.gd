class_name UnsplashSource extends WallpaperSource

func _init():
	super("V_VH42sqX29wh4D2hA9d2N0p5se0xmjNZ1N3K-KJAMg", "https://api.unsplash.com/search/photos", "unsplash")

func get_request_data(query: String) -> Array:
	var q = query.uri_encode() if query != "" else "wallpapers".uri_encode()
	return [base_url + "?query=" + q + "&per_page=30&page=" + str(randi_range(1,10)) + "&client_id=" + api_key]

func get_headers() -> Array:
	return []

func parse_response(data: Dictionary) -> Array:
	var items = []
	for photo in data.get("results", []):
		var urls = photo.get("urls", {})
		var w = photo.get("width", 0)
		var h = photo.get("height", 0)
		if w > h and w > 0:
			items.append({
				"id": str(photo.get("id", "")),
				"display_url": urls.get("small", ""),
				"full_url": urls.get("full", "")
			})
	return items
