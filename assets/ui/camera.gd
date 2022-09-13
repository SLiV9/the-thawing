extends ViewportContainer

onready var world = self.find_node("World")

func switch_to_cinematic(section_id):
	world.switch_to_cinematic(section_id)
	material.set_shader_param("discolor", true)
	$CameraHint.hint_tooltip = world.visual_description_of_cinematic()

func switch_to_facecam(id):
	world.switch_to_facecam(id)
	material.set_shader_param("discolor", false)
	$CameraHint.hint_tooltip = PersonnelData.visual_description_of_speaker(id)


func _on_Chat_cinematic_started(section_id):
	yield(get_tree(), "idle_frame")
	return switch_to_cinematic(section_id)

func _on_Chat_speaker_updated(speaker_id):
	yield(get_tree(), "idle_frame")
	return switch_to_facecam(speaker_id)
