extends Node

var data: ConfigFile
var history = []

func _ready():
	data = ConfigFile.new()
	var err = data.load("res://assets/dialogue_tree.toml")
	if err != OK:
		printerr("Failed to load dialogue_tree")

func start():
	history = []
	return next("intro.setting")

func next(section):
	history.append(section)
	return _load(section)

func rewind():
	history.pop_back()
	var previous_section = history.back()
	if previous_section != null:
		return _load(previous_section)
	else:
		return start()

func can_rewind():
	return history.size() >= 2

func _load(section):
	var speaker = data.get_value(section, "speaker")
	var text = data.get_value(section, "text")
	var raw_options = data.get_value(section, "options")
	var options = []
	for option in raw_options:
		options.append({
			"text": option[0],
			"next_section": option[1],
			"current_section": section,
			"is_implicit": option[0].empty() or speaker.empty(),
		})
	return {
		"speaker": speaker,
		"text": text,
		"options": options,
		"current_section": section,
	}
