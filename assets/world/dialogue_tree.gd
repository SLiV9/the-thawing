extends Node

var data: ConfigFile


func _ready():
	data = ConfigFile.new()
	var err = data.load("res://assets/dialogue_tree.toml")
	if err != OK:
		printerr("Failed to load dialogue_tree")

func start():
	return next("intro.greeting")

func next(section):
	var speaker = data.get_value(section, "speaker")
	var text = data.get_value(section, "text")
	var raw_options = data.get_value(section, "options")
	var options = []
	for option in raw_options:
		options.append({
			"text": option[0],
			"next_section": option[1],
		})
	return {
		"speaker": speaker,
		"text": text,
		"options": options
	}

func display_name_of_speaker(speaker):
	match speaker:
		"graham":
			return "GRAHAM"
