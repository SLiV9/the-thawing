extends VBoxContainer

signal rewind_availability_updated(enabled)
signal speaker_updated(speaker)

onready var scroll = self.get_parent()
onready var scrollbar = scroll.get_v_scrollbar()
onready var dimmed_text_color = self.get_color("font_color", "LinkButton")

var remaining_text_fragments = []
var stored_options = []

func _ready():
	for child in self.get_children():
		if not child is Timer:
			self.remove_child(child)
	handle_dialogue(DialogueTree.start())

func handle_dialogue(x):
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
	if x.speaker.empty():
		# TODO set scene in camera
		text = text
	else:
		emit_signal("speaker_updated", x.speaker)
		var speaker_name = PersonnelData.display_name_of_speaker(x.speaker)
		text = "%s:\n%s" % [speaker_name, text]
	var question = RichTextLabel.new()
	question.fit_content_height = true
	question.text = text
	question.add_to_group("questions")
	self.add_child(question)
	if remaining_text_fragments.empty():
		add_answer_options(x.options)
	else:
		stored_options = x.options
		add_continuation_option()
	scroll_to_bottom()

func add_answer_options(options):
	for option in options:
		var link = LinkButton.new()
		if option.text.empty():
			link.text = "> CONTINUE"
		else:
			link.text = "> %s" % [option.text]
		link.underline = LinkButton.UNDERLINE_MODE_NEVER
		link.focus_mode = Control.FOCUS_ALL
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

func add_continuation(text):
	var continuation = RichTextLabel.new()
	continuation.fit_content_height = true
	continuation.text = text
	continuation.add_to_group("continuations")
	self.add_child(continuation)
	if remaining_text_fragments.empty():
		add_answer_options(stored_options)
	else:
		add_continuation_option()
	scroll_to_bottom()

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
	handle_dialogue(DialogueTree.next(option.next_section))


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
	handle_dialogue(DialogueTree.rewind())
