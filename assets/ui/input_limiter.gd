class_name InputLimiter
extends Node

var is_cooldown_enabled = false
var cooldown_duration = 0.5
var show_input_blocked = false
var disable_key_echo = false

var _is_functional = true
var _cooldown_end_delay = 0
var _was_disabled_this_frame = false
var _info_highlight_end_delay = null

const INFO_HIGHLIGHT_DURATION = 0.1


func _ready():
	$Info.visible = false


func _input(event):
	if event.is_echo():
		if self.disable_key_echo:
			get_tree().set_input_as_handled()
			return
	if not self.is_cooldown_enabled or not self._is_functional:
		return
	if _cooldown_end_delay > 0 and not _was_disabled_this_frame:
		if event is InputEventKey:
			if event.pressed:
				_info_highlight_end_delay = INFO_HIGHLIGHT_DURATION
			get_tree().set_input_as_handled()
		if event is InputEventJoypadButton:
			if event.pressed:
				_info_highlight_end_delay = INFO_HIGHLIGHT_DURATION
			get_tree().set_input_as_handled()
		if event is InputEventMouseButton:
			if event.pressed:
				_info_highlight_end_delay = INFO_HIGHLIGHT_DURATION
				$Info.rect_position = (get_viewport().get_mouse_position() +
					Vector2(20, 0))
			get_tree().set_input_as_handled()
		return
	if event.is_action_pressed("ui_focus_next"):
		_disable_input()
	if event.is_action_pressed("ui_focus_prev"):
		_disable_input()
	if event.is_action_pressed("ui_left"):
		_disable_input()
	if event.is_action_pressed("ui_right"):
		_disable_input()
	if event.is_action_pressed("ui_up"):
		_disable_input()
	if event.is_action_pressed("ui_down"):
		_disable_input()
	if event.is_action_pressed("focus_rewind_button"):
		_disable_input()
	if event.is_action_pressed("focus_personnel_files"):
		_disable_input()
	if event.is_action_pressed("focus_answer1"):
		_disable_input()
	if event.is_action_pressed("focus_answer2"):
		_disable_input()
	if event.is_action_pressed("focus_answer3"):
		_disable_input()


func _process(delta):
	if _cooldown_end_delay > 0:
		if _info_highlight_end_delay != null and self.show_input_blocked:
			$Info.visible = true
			$Info/Bar.rect_size.x = $Info/Label.rect_size.x * min(1,
				_cooldown_end_delay / (0.8 * self.cooldown_duration))
			if _info_highlight_end_delay > 0:
				var highlight = (_info_highlight_end_delay
					/ INFO_HIGHLIGHT_DURATION)
				$Info.modulate.a = 0.5 + 0.5 * highlight
				_info_highlight_end_delay -= delta
			else:
				$Info.modulate.a = 0.5
		_cooldown_end_delay -= delta
	elif $Info.visible:
		$Info.visible = false
		_info_highlight_end_delay = null
		$Info.rect_position = Vector2(10, 10)
	_was_disabled_this_frame = false


func _disable_input():
	if not self.is_cooldown_enabled or not self._is_functional:
		return
	if _cooldown_end_delay > 0:
		return
	_cooldown_end_delay = self.cooldown_duration
	_was_disabled_this_frame = true


func configure(settings):
	self.is_cooldown_enabled = settings.get_value(
		"accessibility", "input_cooldown_enabled", true)
	self.cooldown_duration = settings.get_value(
		"accessibility", "input_cooldown_duration", 0.5)
	self.show_input_blocked = settings.get_value(
		"accessibility", "show_input_blocked", true)
	self.disable_key_echo = settings.get_value(
		"accessibility", "disable_key_echo", false)
	if self.is_cooldown_enabled:
		_disable_input()
	else:
		_cooldown_end_delay = -1


func trigger():
	_disable_input()


func _on_any_button_pressed():
	_disable_input()
