extends ViewportContainer

signal cinematic_started(visual_description)

onready var world = self.find_node("World")


func switch_to_cinematic(section_id):
	world.switch_to_cinematic(section_id)
	material.set_shader_param("discolor", true)
	var visual_description = world.visual_description_of_cinematic()
	emit_signal("cinematic_started", visual_description)
	$CameraHint.hint_tooltip = visual_description

func switch_to_facecam(id):
	world.switch_to_facecam(id)
	material.set_shader_param("discolor", false)
	var visual_description = PersonnelData.visual_description_of_speaker(id)
	$CameraHint.hint_tooltip = visual_description


func _on_Chat_cinematic_started(section_id):
	yield(get_tree(), "idle_frame")
	return switch_to_cinematic(section_id)

func _on_Chat_speaker_updated(speaker_id):
	yield(get_tree(), "idle_frame")
	return switch_to_facecam(speaker_id)
