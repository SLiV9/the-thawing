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
	$InputLimiter.configure(settings)
	settings.apply_accessibility_to_button(
		find_node("SaveAndContinueButton"), $InputLimiter)
	settings.apply_accessibility_to_button(
		find_node("DiscardAndContinueButton"), $InputLimiter)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var button = find_node("SaveAndContinueButton")
		button.grab_click_focus()
		button.grab_focus()

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

func initialize_checkbox(section, item, node_name, default = false):
	if settings.get_value(section, item, default):
		var checkbox = find_node(node_name)
		if checkbox != null:
			checkbox.set_pressed_no_signal(true)


func _on_SaveAndContinueButton_pressed():
	save_and_exit()
	$InputLimiter.trigger()


func _on_ScreenReaderCheckButton_toggled(button_pressed):
	$ScreenReader.enabled = button_pressed
	settings.set_value("accessibility", "screen_reader_enabled", button_pressed)
	# Little hack: select something else, then ScreenReaderCheckButton again.
	# This causes the screen reader to read out the value.
	find_node("SaveAndContinueButton").grab_focus()
	find_node("ScreenReaderCheckButton").grab_focus()
	$InputLimiter.trigger()


func _on_DiscardAndContinueButton_pressed():
	exit()
	$InputLimiter.trigger()


func _on_RemovePrefixCheckBox_toggled(button_pressed):
	settings.set_value("accessibility", "remove_button_prefix", button_pressed)
	$InputLimiter.trigger()


func _on_RemovePrefixCheckBox_ready():
	initialize_checkbox("accessibility", "remove_button_prefix",
		"RemovePrefixCheckBox")


func _on_RemovePeriodsCheckBox_toggled(button_pressed):
	settings.set_value("accessibility", "remove_button_periods", button_pressed)
	$InputLimiter.trigger()


func _on_RemovePeriodsCheckBox_ready():
	initialize_checkbox("accessibility", "remove_button_periods",
		"RemovePeriodsCheckBox")


func _on_InputCooldownCheckButton_ready():
	initialize_checkbox("accessibility", "input_cooldown_enabled",
		"InputCooldownCheckButton", true)


func _on_InputCooldownCheckButton_toggled(button_pressed):
	settings.set_value("accessibility", "input_cooldown_enabled", button_pressed)
	$InputLimiter.is_cooldown_enabled = button_pressed
	$InputLimiter.trigger()


func _on_InputBlockedNotifierCheckBox_ready():
	initialize_checkbox("accessibility", "show_input_blocked",
		"InputBlockedNotifierCheckBox", true)


func _on_InputBlockedNotifierCheckBox_toggled(button_pressed):
	settings.set_value("accessibility", "show_input_blocked", button_pressed)
	$InputLimiter.show_input_blocked = button_pressed


func _on_DisableKeyEchoCheckBox_ready():
	initialize_checkbox("accessibility", "disable_key_echo",
		"DisableKeyEchoCheckBox")


func _on_DisableKeyEchoCheckBox_toggled(button_pressed):
	settings.set_value("accessibility", "disable_key_echo", button_pressed)
	$InputLimiter.disable_key_echo = button_pressed


func _on_FullSettingsButton_ready():
	settings.apply_accessibility_to_button(
		find_node("FullSettingsButton"), $InputLimiter)


func _on_FullSettingsButton_pressed():
	self.is_submenu = true
	save_and_exit()


func _on_InputCooldownRadio003_ready():
	var value = settings.get_value(
		"accessibility", "input_cooldown_duration", 0.5)
	var node_name = "InputCooldownRadio050"
	if value < 0.030 + 0.01:
		node_name = "InputCooldownRadio003"
	elif value < 0.10 + 0.01:
		node_name = "InputCooldownRadio010"
	elif value < 0.25 + 0.01:
		node_name = "InputCooldownRadio025"
	else:
		node_name = "InputCooldownRadio050"
	var checkbox = find_node(node_name)
	if checkbox != null:
		checkbox.set_pressed_no_signal(true)


func _on_InputCooldownRadio003_toggled(button_pressed):
	if button_pressed:
		var value = 0.03
		settings.set_value("accessibility", "input_cooldown_duration", value)
		$InputLimiter.cooldown_duration = value


func _on_InputCooldownRadio010_toggled(button_pressed):
	if button_pressed:
		var value = 0.10
		settings.set_value("accessibility", "input_cooldown_duration", value)
		$InputLimiter.cooldown_duration = value


func _on_InputCooldownRadio025_toggled(button_pressed):
	if button_pressed:
		var value = 0.25
		settings.set_value("accessibility", "input_cooldown_duration", value)
		$InputLimiter.cooldown_duration = value


func _on_InputCooldownRadio050_toggled(button_pressed):
	if button_pressed:
		var value = 0.50
		settings.set_value("accessibility", "input_cooldown_duration", value)
		$InputLimiter.cooldown_duration = value
