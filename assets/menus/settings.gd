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

func apply_accessibility_to_button(button):
	if button == null:
		return
	if self.get_value("accessibility", "remove_button_prefix", false):
		var text = button.text.replace(">", "").replace("<", "")
		text = text.replace("[", "").replace("]", "")
		button.text = text.strip_edges()
