extends Node

var data: ConfigFile
var history = []

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

func get_ids():
	return data.get_sections()

func frame_of_speaker(id):
	return data.get_value(id, "headshot_frame")

func index_name(id):
	return data.get_value(id, "index_name")

func display_name_of_speaker(id):
	return data.get_value(id, "speaker_name")

func visual_description_of_speaker(id):
	return data.get_value(id, "visual_description")

func personal_details(id):
	var full_name = data.get_value(id, "full_name")
	var expertise = data.get_value(id, "expertise")
	var born = data.get_value(id, "born")
	var allergies = data.get_value(id, "allergies")
	var hobbies = data.get_value(id, "hobbies")
	return TEMPLATE % [
		full_name, expertise, born, allergies, hobbies
	]
