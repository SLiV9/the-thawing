extends Node

var data: ConfigFile
var history = []
var flags = FlagCounter.new()
var first_section

var _fast_forward_offset = 0

func _ready():
	data = ConfigFile.new()
	var err = data.load("res://assets/dialogue_tree.toml")
	if err != OK:
		printerr("Failed to load dialogue_tree")
	for section in data.get_sections():
		if section != null and not section.empty():
			first_section = section
			break
	load_history()

func start():
	_fast_forward_offset = 0
	history = []
	var section = first_section
	history.append({
		"section": section,
		"originating_answer_offset": 0,
		"flags_added": null,
	})
	return _load(section)

func next(answer):
	_fast_forward_offset = 0
	history.append({
		"section": answer.next_section,
		"originating_answer_offset": answer.answer_offset,
		"flags_added": null,
	})
	var loaded = _load(answer.next_section)
	save_history()
	return loaded

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
	var discarded = history.pop_back()
	for flag in discarded.flags_added:
		self.flags.pop(flag)
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
		var is_implicit = option[0].empty() or speaker.empty()
		var answer_text = option[0].trim_prefix("!")
		var is_action = (answer_text != option[0])
		options.append({
			"answer_offset": answer_offset,
			"text": answer_text,
			"next_section": option[1],
			"current_section": section,
			"is_implicit": is_implicit,
			"is_action": is_action,
		})
		answer_offset += 1
	if history.back().flags_added == null:
		var section_flags = data.get_value(section, "flags", [])
		for flag in section_flags:
			flags.push(flag)
		history.back().flags_added = section_flags
	var speaker_is_new = data.get_value(section, "speaker_is_new", false)
	var tensity = data.get_value(section, "tensity", -1)
	return {
		"speaker": speaker,
		"speaker_is_new": speaker_is_new,
		"tensity": tensity,
		"text": text,
		"options": options,
		"current_section": section,
	}

func has_personnel_files():
	return flags.count_difference("pc_online", "pc_offline") > 0

func save_history():
	var file = File.new()
	file.open("user://progress.save", File.WRITE)
	var save_data = {
		"history": history,
		"flags": flags.get_save_data(),
	}
	var json = to_json(save_data)
	file.store_line(json)
	file.close()

func load_history():
	var file = File.new()
	file.open("user://progress.save", File.READ)
	var line = file.get_line()
	file.close()
	var save_data = parse_json(line)
	history = save_data.history
	flags.load_from_data(save_data.flags)
	_fast_forward_offset = 0
