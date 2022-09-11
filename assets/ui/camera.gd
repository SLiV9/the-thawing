extends ViewportContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Game_face_cam_disabled():
	material.set_shader_param("discolor", true)


func _on_Game_face_cam_enabled():
	material.set_shader_param("discolor", false)
