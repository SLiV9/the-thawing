extends Camera2D

onready var face = self.find_node("Face")
onready var snow = self.find_node("Snow")

func switch_to_snow():
	self.position = snow.position

func switch_to_facecam(id):
	face.frame = PersonnelData.frame_of_speaker(id)
	self.position = face.position
