extends Node

var data: ConfigFile
var history = []
var flags = FlagCounter.new()
var first_section = null
var all_sections = []

var _fast_forward_offset = 0

func _ready():
	data = ConfigFile.new()
	var err = data.load("res://assets/dialogue_tree.toml")
	if err != OK:
		printerr("Failed to load dialogue_tree")
	all_sections = []
	for section in data.get_sections():
		if section != null and not section.empty():
			if first_section == null:
				first_section = section
			all_sections.append(section)
	if OS.has_feature("editor"):
		test_all_sections()
	load_history()

func test_all_sections():
	for section in all_sections:
			var _discarded = _load(section)

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
	if answer.next_section == first_section:
		return start()
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
	var last_section = history.back().section
	while not are_same_chapter(section, last_section):
		section = history[_fast_forward_offset].section
		_fast_forward_offset += 1
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
	return history.size() >= 2 and are_same_chapter(
			history[history.size() - 2].section,
			history[history.size() - 1].section)

func _load(section):
	var speaker = data.get_value(section, "speaker")
	var text = data.get_value(section, "text")
	var raw_options = data.get_value(section, "options")
	var options = []
	var answer_offset = 0
	for option in raw_options:
		if option.size() >= 3:
			var conditions = option[2]
			if not flags.meets_conditions(conditions):
				continue
		var is_implicit = option[0].empty() or speaker.empty()
		assert(not option[0].begins_with("!"))
		var is_action = option[0].begins_with("~")
		var answer_text = option[0].trim_prefix("~")
		var next_section = option[1]
		assert(all_sections.has(next_section))
		options.append({
			"answer_offset": answer_offset,
			"text": answer_text,
			"next_section": next_section,
			"current_section": section,
			"is_implicit": is_implicit,
			"is_action": is_action,
		})
		answer_offset += 1
	if not history.empty() and history.back().flags_added == null:
		var section_flags = data.get_value(section, "flags", [])
		for flag in section_flags:
			flags.push(flag)
		history.back().flags_added = section_flags
	var speaker_is_new = data.get_value(section, "speaker_is_new", false)
	var tensity = data.get_value(section, "tensity", -1)
	var is_new_chapter = history.size() < 2 or not are_same_chapter(
			history[history.size() - 2].section,
			history[history.size() - 1].section)
	return {
		"speaker": speaker,
		"speaker_is_new": speaker_is_new,
		"tensity": tensity,
		"text": text,
		"options": options,
		"current_section": section,
		"is_new_chapter": is_new_chapter,
	}

func are_same_chapter(a, b):
	var aa = a.rsplit(".", false, 1)[0]
	var bb = b.rsplit(".", false, 1)[0]
	return aa == bb

func has_personnel_files():
	return flags.count_difference("pc_online", "pc_offline") > 0

func has_personnel_files_for_first_time():
	return (flags.count("pc_online") == 1)

func is_dead(id):
	return flags.count("dead_%s" % [id]) > 0

func has_rules_of_robotics():
	return flags.count("rules_of_robotics") > 0

func has_perimeter_logs():
	return flags.count("perimeter_logs") > 0

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
