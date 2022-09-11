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
		$ScreenReader.TTS.speak("In Game", true)
		$ScreenReader.set_initial_screen_focus()
	elif InputController.prefer_joypad_over_keyboard:
		$ScreenReader.set_initial_screen_focus()
	emit_signal("face_cam_enabled")


func _on_StopButton_pressed():
	# TODO save progress
	goto_main_menu()
	

func goto_main_menu():
	var err = get_tree().change_scene(
		"res://assets/menus/main_menu.tscn")
	if err != OK:
		pass
