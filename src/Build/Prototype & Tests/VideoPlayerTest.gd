extends Control

const VIDEO_PATH: String = "C:/Users/youel/Desktop/Projects/C++/Dear-Wallpaper/src/WALLPAPER.mp4"
var video_res: VideoRes

var video_display: TextureRect
var audio_player: AudioStreamPlayer
var wallpaper_helper: DesktopWallpaperHelper

var current_frame: int = 1
var max_frame: int = 0
var loop_count: int = 0

var framerate: float = 0.0
var frame_time: float = 0.0
var saved_audio_pos: float = 0.0

var is_playing: bool = false
var is_attached_to_desktop: bool = false
var should_loop: bool = true

func _ready() -> void:
	#var window = WindowManager.popup_window(Vector2(1920, 1080), "Test", false, false, 0)
	var window = self
	video_res = VideoRes.new()
	video_res.open_video(VIDEO_PATH)
	
	framerate = video_res.get_frame_rate()
	max_frame = video_res.total_frames()
	frame_time = 1.0 / framerate
	current_frame = 1
	
	video_display = TextureRect.new()
	video_display.set_anchors_preset(Container.PRESET_FULL_RECT)
	video_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	video_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	video_display.texture = ImageTexture.new()
	video_display.texture.set_image(video_res.seek_frame(current_frame))
	
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = video_res.get_audio_stream()
	
	#wallpaper_helper = DesktopWallpaperHelper.new()
	#wallpaper_helper.set_target_window_by_title("Test")
	#attach_to_desktop()
	
	window.add_child(video_display)
	window.add_child(audio_player)
	
	play_video()

func attach_to_desktop():
	if wallpaper_helper and not is_attached_to_desktop:
		wallpaper_helper.attach_to_desktop()
		is_attached_to_desktop = true

func detach_from_desktop():
	if wallpaper_helper and is_attached_to_desktop:
		wallpaper_helper.detach_from_desktop()
		is_attached_to_desktop = false

func play_video() -> void:
	is_playing = true
	audio_player.play(saved_audio_pos)
	
	var audio_time = audio_player.get_playback_position()
	current_frame = clamp(int(audio_time * framerate) + 1, 1, max_frame)
	video_display.texture.set_image(video_res.seek_frame(current_frame))

func start() -> void:
	is_playing = false
	saved_audio_pos = audio_player.get_playback_position()
	audio_player.stop()

func _process(delta: float) -> void:
	if not is_playing:
		return
	
	if not audio_player.playing and should_loop:
		restart_video()
		return
		
	if audio_player.playing:
		var audio_time = audio_player.get_playback_position()
		var expected_frame = clamp(int(audio_time * framerate) + 1, 1, max_frame)
		
		if expected_frame >= max_frame and should_loop:
			restart_video()
			return
		
		if expected_frame != current_frame:
			current_frame = expected_frame
			video_display.texture.set_image(video_res.seek_frame(current_frame))

func restart_video():
	current_frame = 1
	saved_audio_pos = 0.0
	loop_count += 1
	audio_player.stop()
	await get_tree().process_frame
	audio_player.play(0.0)
	video_display.texture.set_image(video_res.seek_frame(current_frame))
	#print("Video looped - Loop count: ", loop_count)

func enable_loop():
	should_loop = true

func disable_loop():
	should_loop = false

func reset_loop_count():
	loop_count = 0

func _exit_tree():
	if wallpaper_helper:
		detach_from_desktop()
		wallpaper_helper = null

func refresh_wallpaper():
	if wallpaper_helper:
		wallpaper_helper.refresh_wallpaper()

func toggle_wallpaper():
	if is_attached_to_desktop:
		detach_from_desktop()
	else:
		attach_to_desktop()
