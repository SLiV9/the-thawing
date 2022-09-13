extends Camera2D

onready var face = self.find_node("Face")
onready var cinematic = $Snow

func switch_to_cinematic(section_id):
	var subpath = section_id.replace(".", "/")
	var path = "res://assets/world/scenes/%s.tscn" % [subpath]
	if ResourceLoader.exists(path):
		self.remove_child(cinematic)
		var cinematic_scene = load(path)
		cinematic = cinematic_scene.instance()
		self.add_child(cinematic)
	face.visible = false
	cinematic.visible = true

func switch_to_facecam(speaker_id):
	face.frame = PersonnelData.frame_of_speaker(speaker_id)
	face.visible = true
	cinematic.visible = false

func visual_description_of_cinematic():
	var background = cinematic.find_node("Background")
	return background.hint_tooltip
