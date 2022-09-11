extends VBoxContainer

onready var overview = self.find_node("Overview")
onready var details = self.find_node("Details")
onready var headshot = self.find_node("Headshot")
onready var detailstext = self.find_node("DetailsText")

var data: ConfigFile
var workers = []
var selected = null
var dead_workers = []

const TEMPLATE = """NAME: %s
EXPERTISE: %s
BORN: %s
ALLERGIES: %s
HOBBIES: %s"""

func _ready():
	data = ConfigFile.new()
	var err = data.load("res://assets/personnel_data.toml")
	if err != OK:
		printerr("Failed to load personnel_data")
	details.visible = false
	workers = data.get_sections()
	for id in workers:
		var link = LinkButton.new()
		link.text = "> %s" % [DialogueTree.display_name_of_speaker(id)]
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
	overview.visible = false
	details.visible = true
	var display_name = DialogueTree.display_name_of_speaker(id)
	if dead_workers.has(id):
		$PersonnelHeader.text = "%s (DECEASED)" % [display_name]
	else:
		$PersonnelHeader.text = display_name
	var headshot_frame = data.get_value(id, "headshot_frame")
	headshot.frame = headshot_frame
	var full_name = data.get_value(id, "full_name")
	var expertise = data.get_value(id, "expertise")
	var born = data.get_value(id, "born")
	var allergies = data.get_value(id, "allergies")
	var hobbies = data.get_value(id, "hobbies")
	detailstext.text = TEMPLATE % [
		full_name, expertise, born, allergies, hobbies
	]


func _on_BackButton_pressed():
	overview.visible = true
	details.visible = false
	$PersonnelHeader.text = "OVERVIEW"
