extends VBoxContainer

onready var menu = self.find_node("Menu")
onready var overview = self.find_node("Overview")
onready var details = self.find_node("Details")
onready var headshot = self.find_node("Headshot")
onready var detailstext = self.find_node("DetailsText")

var workers = []
var selected = null
var dead_workers = []

func _ready():
	menu.visible = true
	overview.visible = false
	details.visible = false
	workers = PersonnelData.get_ids()
	for id in workers:
		var link = LinkButton.new()
		link.text = "> %s" % [PersonnelData.index_name(id)]
		link.underline = LinkButton.UNDERLINE_MODE_NEVER
		link.focus_mode = Control.FOCUS_ALL
		link.connect("pressed", self, "_on_selected", [id])
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
		$PersonnelHeader.text = "%s (DECEASED)" % [display_name]
	else:
		$PersonnelHeader.text = display_name
	headshot.frame = PersonnelData.frame_of_speaker(id)
	detailstext.text = PersonnelData.personal_details(id)


func _on_BackButton_pressed():
	menu.visible = true
	overview.visible = false
	details.visible = false
	$PersonnelHeader.text = "INDEX"


func _on_ListButton_pressed():
	menu.visible = false
	overview.visible = true
	details.visible = false
	$PersonnelHeader.text = "ALL PERSONNEL"
