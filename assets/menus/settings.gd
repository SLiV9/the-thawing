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
