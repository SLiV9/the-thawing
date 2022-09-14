extends Control


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
	if settings.get_value("accessibility", "screen_reader_enabled", true):
		PersonnelData.data.set_value("alex", "speaker_name", "ALEX")
	else:
		PersonnelData.data.set_value("alex", "speaker_name", "AL3X")
	settings.apply_accessibility_to_button(find_node("ListButton"))
	settings.apply_accessibility_to_button(find_node("BackButton"))
	settings.apply_accessibility_to_button(find_node("RewindButton"))
	settings.apply_accessibility_to_button(find_node("StopButton"))


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var button = find_node("StopButton")
		button.grab_click_focus()
		button.grab_focus()
	elif event.is_action_pressed("focus_rewind_button"):
		var button = find_node("RewindButton")
		button.grab_click_focus()
		button.grab_focus()
	elif event.is_action_pressed("focus_personnel_files"):
		var pfiles = find_node("PersonnelInfo")
		var element = $ScreenReader.find_focusable_control(pfiles)
		if element != null:
			element.grab_click_focus()
			element.grab_focus()


func _on_StopButton_pressed():
	# TODO save progress
	goto_main_menu()
	

func goto_main_menu():
	var err = get_tree().change_scene(
		"res://assets/menus/main_menu.tscn")
	if err != OK:
		pass


func _on_Camera_cinematic_started(visual_description):
	if visual_description.empty():
		return
	print(visual_description)
	$ScreenReader.TTS.speak(visual_description, false)


func _on_Chat_speaker_introduced(id):
	var visual_description = PersonnelData.visual_description_of_speaker(id)
	print(visual_description)
	$ScreenReader.TTS.speak(visual_description, false)


func _on_Chat_text_added(speaker_id, text):
	if text.empty():
		return
	var audio_description = text
	if not speaker_id.empty():
		var speaker_name = PersonnelData.display_name_of_speaker(speaker_id)
		audio_description = "%s: %s" % [speaker_name, audio_description]
	print(audio_description)
	$ScreenReader.TTS.speak(audio_description, false)


func _on_Chat_speech_interrupted():
	$ScreenReader.TTS.stop()
