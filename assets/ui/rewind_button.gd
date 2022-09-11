extends LinkButton




func _on_Chat_rewind_availability_updated(enabled):
	self.visible = enabled
	if enabled:
		self.grab_click_focus()
		self.grab_focus()
