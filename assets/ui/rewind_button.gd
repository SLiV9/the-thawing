extends LinkButton


func _unhandled_input(event):
	if event.is_action_pressed("focus_rewind_button"):
		self.grab_click_focus()
		self.grab_focus()


func _on_Chat_rewind_availability_updated(enabled):
	self.visible = enabled
