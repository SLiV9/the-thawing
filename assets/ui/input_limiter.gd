class_name InputLimiter
extends Timer

var is_cooldown_enabled = false
var cooldown_period = 0.5

var _is_functional = true


func _ready():
	var err = self.connect("timeout", self, "_on_timeout")
	if err != OK:
		printerr("failed to connect timeout: ", err)
		self._is_functional = false


func _input(event):
	if not self.is_cooldown_enabled or not self._is_functional:
		return
	# Disable input after key release (so that the pressed event triggers).
	if event is InputEventKey and not event.pressed:
		_disable_input()
	if event is InputEventJoypadButton and not event.pressed:
		_disable_input()


func enable_input():
	get_tree().get_root().set_disable_input(false)

func _disable_input():
	if not self.is_cooldown_enabled or not self._is_functional:
		return
	if self.time_left > 0:
		return
	get_tree().get_root().set_disable_input(true)
	self.start(self.cooldown_period)


func configure(settings):
	self.is_cooldown_enabled = settings.get_value(
		"accessibility", "input_cooldown_enabled", true)
	if self.is_cooldown_enabled:
		_disable_input()
	else:
		enable_input()

func trigger():
	_disable_input()


func _on_timeout():
	enable_input()


func _on_any_button_pressed():
	_disable_input()
