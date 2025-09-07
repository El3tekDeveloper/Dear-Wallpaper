class_name WallpaperSource extends RefCounted

var api_key: String
var base_url: String
var name: String

func _init(key: String, url: String, source_name: String):
	api_key = key
	base_url = url
	name = source_name

func get_request_data(query: String) -> Array:
	return []

func get_headers() -> Array:
	return []

func parse_response(data: Dictionary) -> Array:
	return []

func is_landscape_content(item: Dictionary) -> bool:
	return true
