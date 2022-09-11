extends Control


signal face_cam_enabled()
signal face_cam_disabled()


var settings = Settings.new()


func _ready():
	settings.load_all()
	if settings.get_value("graphics", "enable_fullscreen", false):
		OS.window_fullscreen = true
	if settings.get_value("accessibility", "screen_reader_enabled", true):
		$ScreenReader.enabled = true
		#$ScreenReader.TTS.speak("Gameplay", true)
		$ScreenReader.set_initial_screen_focus()
	elif InputController.prefer_joypad_over_keyboard:
		$ScreenReader.set_initial_screen_focus()
	emit_signal("face_cam_enabled")
