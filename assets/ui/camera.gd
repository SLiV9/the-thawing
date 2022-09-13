extends ViewportContainer

onready var world = self.find_node("World")

func switch_to_world():
	world.switch_to_snow()
	material.set_shader_param("discolor", true)

func switch_to_facecam(id):
	world.switch_to_facecam(id)
	material.set_shader_param("discolor", false)
	$CameraHint.hint_tooltip = PersonnelData.visual_description_of_speaker(id)


func _on_Chat_speaker_updated(speaker):
	return switch_to_facecam(speaker)
