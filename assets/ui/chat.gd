extends VBoxContainer

signal rewind_availability_updated(enabled)

onready var scroll = self.get_parent()
onready var scrollbar = scroll.get_v_scrollbar()
onready var dimmed_text_color = self.get_color("font_color", "LinkButton")

func _ready():
	for child in self.get_children():
		self.remove_child(child)
	handle_dialogue(DialogueTree.start())
	
func handle_dialogue(x):
	emit_signal("rewind_availability_updated", DialogueTree.can_rewind())
	var speaker_name = DialogueTree.display_name_of_speaker(x.speaker)
	var question = RichTextLabel.new()
	question.fit_content_height = true
	question.text = "%s:\n%s" % [speaker_name, x.text]
	question.add_to_group(x.current_section)
	question.add_to_group("questions")
	self.add_child(question)
	for option in x.options:
		var link = LinkButton.new()
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
		answer.add_to_group(x.current_section)
		self.add_child(answer)
	yield(get_tree(), "idle_frame")
	scroll.scroll_vertical = scrollbar.max_value


func _on_answer(option):
	for child in self.get_children():
		if child.is_in_group("available_answers"):
			self.remove_child(child)
	var answer = RichTextLabel.new()
	answer.fit_content_height = true
	answer.text = "YOU:\n%s" % [option.text]
	answer.add_color_override("default_color", dimmed_text_color)
	answer.add_to_group(option.current_section)
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
