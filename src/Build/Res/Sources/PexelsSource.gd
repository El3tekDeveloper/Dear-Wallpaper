class_name PexelsSource extends WallpaperSource

func _init():
	super("OkOdpPsc8moLsdTBqQTGV7NoRyCvrDtVH80QE14QPaYVGS6A2qlGGKar", "https://api.pexels.com/v1/search", "pexels")

func get_request_data(query: String) -> Array:
	var q = query.uri_encode() if query != "" else "wallpapers".uri_encode()
	return [base_url + "?query=" + q + "&per_page=30&page=" + str(randi_range(1,20))]

func get_headers() -> Array:
	return ["Authorization: " + api_key]

func parse_response(data: Dictionary) -> Array:
	var items = []
	for photo in data.get("photos", []):
		var src = photo.get("src", {})
		var w = photo.get("width", 0)
		var h = photo.get("height", 0)
		if w > h and w > 0:
			items.append({
				"id": str(photo.get("id", 0)),
				"display_url": src.get("medium", ""),
				"full_url": src.get("original", "")
			})
	return items
