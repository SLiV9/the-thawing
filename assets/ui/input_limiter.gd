extends Timer

var is_enabled = false

var _is_functional = true


func _ready():
	var err = self.connect("timeout", self, "_on_timeout")
	if err != OK:
		printerr("failed to connect timeout: ", err)
		self._is_functional = false
	self.start()


func _input(event):
	if not self.is_enabled or not self._is_functional:
		return
	# Disable input after key release (so that the pressed event triggers).
	if event is InputEventKey and not event.pressed:
		_disable_input()
	if event is InputEventJoypadButton and not event.pressed:
		_disable_input()


func enable_input():
	get_tree().get_root().set_disable_input(false)

func _disable_input():
	if not self.is_enabled or not self._is_functional:
		return
	if self.time_left > 0:
		return
	get_tree().get_root().set_disable_input(true)
	self.start()


func trigger():
	_disable_input()


func _on_timeout():
	enable_input()
