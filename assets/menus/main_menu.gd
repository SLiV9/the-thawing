extends Control


var settings = Settings.new()


func _ready():
	settings.load_all()
	if not settings.has_section("accessibility"):
		goto_first_launch_settings_menu()
		#return
	if settings.get_value("graphics", "enable_fullscreen", false):
		OS.window_fullscreen = true
	if settings.has_section_key("interface", "text_size"):
		var text_size = settings.get_value("interface", "text_size")
		var main_font = get_font("normal_font", "RichTextLabel")
		main_font.size = text_size
		main_font.update_changes()
		var bold_font = get_font("bold_font", "RichTextLabel")
		bold_font.size = text_size
		bold_font.update_changes()
	if settings.get_value("accessibility", "screen_reader_enabled", true):
		$ScreenReader.enabled = true
		$ScreenReader.TTS.speak("Main Menu", true)
		$ScreenReader.set_initial_screen_focus()
	elif InputController.prefer_joypad_over_keyboard:
		$ScreenReader.set_initial_screen_focus()
	randomize()

func goto_first_launch_settings_menu():
	# TODO implement
	pass
