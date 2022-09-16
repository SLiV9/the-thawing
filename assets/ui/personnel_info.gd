extends VBoxContainer

export var is_online = false

signal button_created(button)
signal screen_changed()

onready var menu = self.find_node("Menu")
onready var overview = self.find_node("Overview")
onready var details = self.find_node("Details")
onready var headshot = self.find_node("Headshot")
onready var detailstext = self.find_node("DetailsText")
onready var header = self.find_node("PersonnelHeader")

var workers = []
var selected = null
var dead_workers = []

func _ready():
	menu.visible = is_online
	overview.visible = false
	details.visible = false
	workers = PersonnelData.get_ids()
	for id in workers:
		var link = LinkButton.new()
		link.text = "> %s" % [PersonnelData.index_name(id)]
		link.underline = LinkButton.UNDERLINE_MODE_NEVER
		link.focus_mode = Control.FOCUS_ALL
		link.connect("pressed", self, "_on_selected", [id])
		emit_signal("button_created", link)
		var answer = MarginContainer.new()
		answer.add_constant_override("margin_top", 2)
		answer.add_constant_override("margin_bottom", 2)
		answer.add_constant_override("margin_right", 8)
		answer.add_constant_override("margin_left", 8)
		answer.add_child(link)
		answer.size_flags_horizontal = SIZE_EXPAND_FILL
		overview.add_child(answer)


func _on_selected(id):
	menu.visible = false
	overview.visible = false
	details.visible = true
	var display_name = PersonnelData.index_name(id)
	if dead_workers.has(id):
		header.text = "%s (DECEASED)" % [display_name]
	else:
		header.text = display_name
	headshot.frame = PersonnelData.frame_of_speaker(id)
	detailstext.text = PersonnelData.personal_details(id)
	emit_signal("screen_changed")
	focus_first_button(details)


func _on_BackButton_pressed():
	to_index()


func to_index():
	header.text = "INDEX"
	menu.visible = true
	overview.visible = false
	details.visible = false
	emit_signal("screen_changed")
	focus_first_button(menu)


func _on_ListButton_pressed():
	to_overview()


func to_overview():
	header.text = "ALL PERSONNEL"
	menu.visible = false
	overview.visible = true
	details.visible = false
	emit_signal("screen_changed")
	focus_first_button(overview)


func _on_Chat_dialogue_tree_updated():
	print(DialogueTree.has_personnel_files(), " vs ", is_online)
	if DialogueTree.has_personnel_files() and not is_online:
		is_online = true
		to_index()
	elif is_online:
		is_online = false
		menu.visible = false
		overview.visible = false
		details.visible = false
		header.text = "OFFLINE"


func focus_first_button(screen):
	var focus = find_focusable_control(screen)
	if not focus:
		return
	focus.grab_click_focus()
	focus.grab_focus()


func find_focusable_control(node):
	if (
		node is Control
		and node.is_visible_in_tree()
		and (node.focus_mode == Control.FOCUS_CLICK or node.focus_mode == Control.FOCUS_ALL)
	):
		return node
	for child in node.get_children():
		var result = find_focusable_control(child)
		if result:
			return result
	return null
