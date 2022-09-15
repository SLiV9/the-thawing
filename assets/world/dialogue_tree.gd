extends Node

var data: ConfigFile
var history = []
var first_section

var _fast_forward_offset = 0

func _ready():
	data = ConfigFile.new()
	var err = data.load("res://assets/dialogue_tree.toml")
	if err != OK:
		printerr("Failed to load dialogue_tree")
	first_section = data.get_sections()[0]

func start():
	_fast_forward_offset = 0
	history = []
	var section = first_section
	history.append({
		"section": section,
		"originating_answer_offset": 0,
	})
	return _load(section)

func next(answer):
	_fast_forward_offset = 0
	history.append({
		"section": answer.next_section,
		"originating_answer_offset": answer.answer_offset,
	})
	return _load(answer.next_section)

func can_fast_forward():
	return _fast_forward_offset < history.size()

func fast_forward_start():
	var section = history[0].section
	_fast_forward_offset = 1
	return _load(section)

func fast_forward_answer_offset():
	return history[_fast_forward_offset].originating_answer_offset

func fast_forward_next():
	var section = history[_fast_forward_offset].section
	_fast_forward_offset += 1
	return _load(section)

func fast_forward_end():
	_fast_forward_offset = 0

func rewind():
	_fast_forward_offset = 0
	history.pop_back()
	var previous = history.back()
	if previous != null:
		return _load(previous.section)
	else:
		return start()

func can_rewind():
	return history.size() >= 2

func _load(section):
	var speaker = data.get_value(section, "speaker")
	var text = data.get_value(section, "text")
	var raw_options = data.get_value(section, "options")
	var options = []
	var answer_offset = 0
	for option in raw_options:
		options.append({
			"answer_offset": answer_offset,
			"text": option[0],
			"next_section": option[1],
			"current_section": section,
			"is_implicit": option[0].empty() or speaker.empty(),
		})
		answer_offset += 1
	var speaker_is_new = data.get_value(section, "speaker_is_new", false)
	return {
		"speaker": speaker,
		"speaker_is_new": speaker_is_new,
		"text": text,
		"options": options,
		"current_section": section,
	}
