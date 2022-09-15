class_name Settings
extends ConfigFile



var _filename = "user://settings.cfg"

func load_all():
	var err = self.load(_filename)
	if err != OK:
		pass

func save_all():
	var err = self.save(_filename)
	if err != OK:
		print_debug("Failed to save '", _filename, "': ", err)

func apply_accessibility_to_button(button, input_limiter: InputLimiter):
	if button == null:
		return
	if (button is Button or button is LinkButton
			or button is CheckButton or button is CheckBox
			or button is Label):
		if self.get_value("accessibility", "remove_button_prefix", false):
			var text = button.text.replace(">", "").replace("<", "")
			text = text.replace("[", "").replace("]", "")
			button.text = text.strip_edges()
		if self.get_value("accessibility", "remove_button_periods", false):
			button.text = button.text.replace(".", "")
	if (button is Button or button is LinkButton
			or button is TextureButton
			or button is CheckButton or button is CheckBox):
		if self.get_value("accessibility", "input_cooldown_enabled", false):
			button.connect("pressed", input_limiter, "_on_any_button_pressed")
