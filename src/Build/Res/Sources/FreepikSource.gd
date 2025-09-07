class_name FreepikSource extends WallpaperSource

func _init():
	super("FPSX8c750eb1bea3eb5f53928b6b119baee2", "https://api.freepik.com/v1/resources", "freepik")

func get_request_data(query: String) -> Array:
	var q = query.uri_encode() if query != "" else "wallpapers".uri_encode()
	return [base_url + "?query=" + q + "&limit=30"]

func get_headers() -> Array:
	return ["Authorization: Bearer " + api_key]

func parse_response(data: Dictionary) -> Array:
	var items = []
	for photo in data.get("data", []):
		var preview_url = photo.get("attributes", {}).get("preview", {}).get("url", "")
		items.append({
			"id": str(photo.get("id", 0)),
			"display_url": preview_url,
			"full_url": preview_url
		})
	return items
