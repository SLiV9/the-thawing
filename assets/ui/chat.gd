extends VBoxContainer

signal rewind_availability_updated(enabled)
signal cinematic_started(section_id)
signal speech_interrupted()
signal speaker_updated(speaker_id)
signal speaker_introduced(speaker_id)
signal text_added(speaker_id, text)
signal button_created(button)

onready var scroll = self.get_parent()
onready var scrollbar = scroll.get_v_scrollbar()
onready var dimmed_text_color = self.get_color("font_color", "LinkButton")
onready var input_limiter = self.get_tree().root.find_node("InputLimiter")

var remaining_text_fragments = []
var stored_options = []

func _ready():
	for child in self.get_children():
		if not child is Timer:
			self.remove_child(child)
	if DialogueTree.can_fast_forward():
		var section = DialogueTree.fast_forward_start()
		while DialogueTree.can_fast_forward():
			var answer_offset = DialogueTree.fast_forward_answer_offset()
			handle_dialogue(section, answer_offset)
			section = DialogueTree.fast_forward_next()
		DialogueTree.fast_forward_end()
		handle_dialogue(section)
	else:
		handle_dialogue(DialogueTree.start())


func _unhandled_input(event):
	if event.is_action_pressed("ui_select") and self.get_focus_owner() == null:
		select_nth_answer(0)
	elif event.is_action_pressed("focus_answer1"):
		select_nth_answer(0)
	elif event.is_action_pressed("focus_answer2"):
		select_nth_answer(1)
	elif event.is_action_pressed("focus_answer3"):
		select_nth_answer(2)


func select_nth_answer(n):
	for child in self.get_children():
		if child.is_in_group("available_answers"):
			if n > 0:
				n -= 1
				continue
			var button = child
			if not button is LinkButton:
				button = button.get_child(0)
			button.grab_click_focus()
			button.grab_focus()
			return


func handle_dialogue(x, fast_forward_answer_offset = null):
	emit_signal("rewind_availability_updated", DialogueTree.can_rewind())
	var text = x.text
	if "\n" in text:
		var first_text = ""
		for fragment in text.split("\n"):
			var fragment_text = fragment.strip_edges()
			if fragment_text.empty():
				pass
			elif first_text.empty():
				first_text = fragment_text
			else:
				remaining_text_fragments.append(fragment_text)
		text = first_text
	if !text.empty():
		var question = RichTextLabel.new()
		question.fit_content_height = true
		question.text = text
		if not x.speaker.empty():
			var speaker_name = PersonnelData.display_name_of_speaker(x.speaker)
			question.text = "%s:\n%s" % [speaker_name, text]
		question.add_to_group("questions")
		self.add_child(question)
	else:
		var gap = Control.new()
		gap.add_to_group("questions")
		self.add_child(gap)
	if fast_forward_answer_offset != null:
		for fragment in remaining_text_fragments:
			add_continuation(fragment, true)
		remaining_text_fragments = []
		var option = x.options[fast_forward_answer_offset]
		add_answer_from_option(option)
		return
	if remaining_text_fragments.empty():
		add_answer_options(x.options)
	else:
		stored_options = x.options
		add_continuation_option()
	scroll_to_bottom()
	yield(get_tree(), "idle_frame")
	emit_signal("speech_interrupted")
	if x.speaker.empty():
		emit_signal("cinematic_started", x.current_section)
		emit_signal("text_added", "", text)
	else:
		emit_signal("speaker_updated", x.speaker)
		if x.speaker_is_new:
			emit_signal("speaker_introduced", x.speaker)
		emit_signal("text_added", x.speaker, text)

func add_answer_options(options):
	for option in options:
		var link = LinkButton.new()
		var text = option.text
		if text.empty():
			text = "> CONTINUE"
		else:
			text = "> %s" % [text]
		link.text = text
		link.underline = LinkButton.UNDERLINE_MODE_NEVER
		link.focus_mode = Control.FOCUS_ALL
		emit_signal("button_created", link)
		link.connect("pressed", self, "_on_answer", [option])
		var answer = MarginContainer.new()
		answer.add_constant_override("margin_top", 2)
		answer.add_constant_override("margin_bottom", 2)
		answer.add_constant_override("margin_right", 8)
		answer.add_child(link)
		answer.add_to_group("available_answers")
		self.add_child(answer)
		if option.text.empty() and options.size() == 1:
			link.grab_click_focus()
			link.grab_focus()

func add_continuation_option():
	var option = {
		"text": "",
		"is_implicit": true,
	}
	add_answer_options([option])

func add_continuation(text, is_fast_forward = false):
	var continuation = RichTextLabel.new()
	continuation.fit_content_height = true
	continuation.text = text
	continuation.add_to_group("continuations")
	self.add_child(continuation)
	if is_fast_forward:
		return
	elif remaining_text_fragments.empty():
		add_answer_options(stored_options)
	else:
		add_continuation_option()
	scroll_to_bottom()
	yield(get_tree(), "idle_frame")
	emit_signal("speech_interrupted")
	emit_signal("text_added", "", text)

func add_answer_from_option(option):
	if option.is_implicit:
		var gap = Control.new()
		gap.rect_min_size.y = 20
		self.add_child(gap)
	else:
		var answer = RichTextLabel.new()
		answer.fit_content_height = true
		answer.text = "YOU:\n%s" % [option.text]
		answer.add_color_override("default_color", dimmed_text_color)
		answer.add_to_group("given_answers")
		self.add_child(answer)

func scroll_to_bottom():
	yield(get_tree(), "idle_frame")
	scroll.scroll_vertical = scrollbar.max_value


func _on_answer(option):
	for child in self.get_children():
		if child.is_in_group("available_answers"):
			self.remove_child(child)
	if !remaining_text_fragments.empty():
		var text = remaining_text_fragments.pop_front()
		add_continuation(text)
		return
	add_answer_from_option(option)
	handle_dialogue(DialogueTree.next(option))


func _on_RewindButton_pressed():
	var current_section_nodes = []
	var previous_section_nodes = []
	for child in self.get_children():
		if child.is_in_group("questions"):
			previous_section_nodes = current_section_nodes
			current_section_nodes = [child]
		else:
			current_section_nodes.append(child)
	for child in previous_section_nodes:
		self.remove_child(child)
	for child in current_section_nodes:
		self.remove_child(child)
	stored_options = []
	remaining_text_fragments = []
	handle_dialogue(DialogueTree.rewind())
