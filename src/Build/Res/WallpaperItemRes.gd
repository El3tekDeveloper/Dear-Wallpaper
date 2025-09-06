class_name WallpaperItemRes extends Resource

signal image_changed(res: WallpaperItemRes)
signal image_saved(path: String)

@export var id: String = "epmty"
@export var title: String = "epmty"
@export var display_url: String = ""
@export var full_url: String = ""
@export var extension: String = ".jpg"

var image: Image = null

func has_image() -> bool:
	return image != null and !image.is_empty()

func get_filename() -> String:
	return id + extension

func save_image(save_dir: String, parent: Node) -> void:
	if full_url == "":
		push_error("No full_url set for this item.")
		return
	
	var req := HTTPRequest.new()
	parent.add_child(req)
	req.request_completed.connect(func(result: int, response_code: int, headers: Array, body: PackedByteArray):
		if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
			push_error("Failed to download full image.")
			req.queue_free()
			return
		
		var img := Image.new()
		var err = img.load_jpg_from_buffer(body)
		if err != OK:
			err = img.load_png_from_buffer(body)
			if err != OK:
				push_error("Unsupported image format.")
				req.queue_free()
				return
		
		var final_path = save_dir.path_join(get_filename())
		err = img.save_png(final_path) if extension == ".png" else img.save_jpg(final_path)
		if err != OK:
			push_error("Failed to save image.")
		else:
			image_saved.emit(final_path)
		req.queue_free()
	)
	req.request(full_url)
