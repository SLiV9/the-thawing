extends VBoxContainer


onready var scroll = self.get_parent()
onready var scrollbar = scroll.get_v_scrollbar()

func _ready():
	for child in self.get_children():
		self.remove_child(child)
	handle_dialogue(DialogueTree.start())
	
func handle_dialogue(x):
	var speaker_name = DialogueTree.display_name_of_speaker(x.speaker)
	var question = RichTextLabel.new()
	question.fit_content_height = true
	question.text = "%s:\n%s" % [speaker_name, x.text]
	self.add_child(question)
	for option in x.options:
		var link = LinkButton.new()
		link.text = "> %s" % [option.text]
		link.underline = LinkButton.UNDERLINE_MODE_NEVER
		link.focus_mode = Control.FOCUS_ALL
		link.connect("pressed", self, "_on_answer", [option.next_section])
		var answer = MarginContainer.new()
		answer.add_constant_override("margin_top", 2)
		answer.add_constant_override("margin_bottom", 2)
		answer.add_constant_override("margin_right", 8)
		answer.add_child(link)
		self.add_child(answer)
	yield(get_tree(), "idle_frame")
	scroll.scroll_vertical = scrollbar.max_value

func _on_answer(next_section):
	handle_dialogue(DialogueTree.next(next_section))
	
