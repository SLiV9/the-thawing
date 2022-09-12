extends Control

export var is_submenu = false
export var is_first_launch_window = false

var settings = Settings.new()


func _init():
	settings.load_all()

func _ready():
	if settings.has_section_key("interface", "text_size"):
		var text_size = settings.get_value("interface", "text_size")
		var main_font = get_font("normal_font", "RichTextLabel")
		main_font.size = text_size
		main_font.update_changes()
	if settings.get_value("accessibility", "screen_reader_enabled", true):
		var checkbutton = find_node("ScreenReaderCheckButton")
		if checkbutton != null:
			checkbutton.set_pressed_no_signal(true)
		$ScreenReader.enabled = true
	if $ScreenReader.enabled:
		if is_submenu:
			$ScreenReader.TTS.stop()
		$ScreenReader.set_initial_screen_focus()
	elif InputController.prefer_joypad_over_keyboard:
		$ScreenReader.set_initial_screen_focus()


func save_and_exit():
	settings.set_value("accessibility", "screen_reader_enabled",
		settings.get_value("accessibility", "screen_reader_enabled", true))
	settings.save_all()
	exit()

func exit():
	var err
	if is_submenu:
		err = get_tree().change_scene("res://assets/menus/settings_menu.tscn")
	else:
		err = get_tree().change_scene("res://assets/menus/main_menu.tscn")
	if err != OK:
		pass


func _on_SaveAndContinueButton_pressed():
	save_and_exit()


func _on_ScreenReaderCheckButton_toggled(button_pressed):
	$ScreenReader.enabled = button_pressed
	settings.set_value("accessibility", "screen_reader_enabled", button_pressed)
	# Little hack: select something else, then ScreenReaderCheckButton again.
	# This causes the screen reader to read out the value.
	find_node("SaveAndContinueButton").grab_focus()
	find_node("ScreenReaderCheckButton").grab_focus()


func _on_DiscardAndContinueButton_pressed():
	exit()
