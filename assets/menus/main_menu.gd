extends Control


var settings = Settings.new()


func _ready():
	settings.load_all()
	if not settings.has_section("accessibility"):
		goto_first_launch_settings_menu()
		return
	if settings.get_value("graphics", "enable_fullscreen", false):
		OS.window_fullscreen = true
	if settings.has_section_key("interface", "text_size"):
		var text_size = settings.get_value("interface", "text_size")
		var main_font = get_font("normal_font", "RichTextLabel")
		main_font.size = text_size
		main_font.update_changes()
	if settings.get_value("accessibility", "screen_reader_enabled", true):
		$ScreenReader.enabled = true
		$ScreenReader.TTS.speak("Main Menu", true)
		$ScreenReader.set_initial_screen_focus()
	elif InputController.prefer_joypad_over_keyboard:
		$ScreenReader.set_initial_screen_focus()
	$InputLimiter.configure(settings)
	if OS.has_feature("HTML5"):
		find_node("QuitButton").visible = false
		find_node("FakeQuitButton").visible = false
	if DialogueTree.can_fast_forward():
		find_node("StartButton").text = "> CONTINUE"
		find_node("FakeStartButton").text = "> CONTINUE"
	settings.apply_accessibility_to_button(find_node("StartButton"), $InputLimiter)
	settings.apply_accessibility_to_button(find_node("SettingsButton"), $InputLimiter)
	settings.apply_accessibility_to_button(find_node("QuitButton"), $InputLimiter)
	settings.apply_accessibility_to_button(find_node("FakeStartButton"), $InputLimiter)
	settings.apply_accessibility_to_button(find_node("FakeSettingsButton"), $InputLimiter)
	settings.apply_accessibility_to_button(find_node("FakeQuitButton"), $InputLimiter)
	if Mixer.running:
		Mixer.enter_main_menu()
	else:
		var tracks = $ResourcePreloader.get_resource("tracks")
		Mixer.run(tracks)
	randomize()

func goto_first_launch_settings_menu():
	var err = get_tree().change_scene(
		"res://assets/menus/first_launch_menu.tscn")
	if err != OK:
		pass

func goto_gameplay():
	var err = get_tree().change_scene(
		"res://assets/ui/ingame.tscn")
	if err != OK:
		pass

func goto_settings_menu():
	var err = get_tree().change_scene(
		"res://assets/menus/settings_menu.tscn")
	if err != OK:
		pass

func quit_game():
	get_tree().quit()


func _on_StartButton_pressed():
	goto_gameplay()
	$InputLimiter.trigger()


func _on_SettingsButton_pressed():
	goto_settings_menu()
	$InputLimiter.trigger()


func _on_QuitButton_pressed():
	quit_game()
	$InputLimiter.trigger()
