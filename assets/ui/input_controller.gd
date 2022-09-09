extends Node

###
### Part of The Thawing
### Originally developed for Cave City Despots
### Copyright (c) 2021 Sander in 't Veld
### License: MIT
###

enum JoypadBrand {
	Default,
	Sony,
}

var prefer_joypad_over_keyboard = false
var preferred_joypad_brand = null
var detected_joypad_brand = null

var _main_joypad_device = null

var _icon_height = 32


func _ready():
	for device in Input.get_connected_joypads():
		__on_joy_connection_changed(device, true)
	var err = Input.connect("joy_connection_changed", self,
		"__on_joy_connection_changed")
	if err != null:
		pass
	var settings = Settings.new()
	settings.load_all()
	if settings.has_section_key("interface", "preferred_joypad_brand"):
		preferred_joypad_brand = settings.get_value(
			"interface", "preferred_joypad_brand")
	if settings.has_section_key("interface", "text_size"):
		var text_size = settings.get_value("interface", "text_size")
		if text_size > 18:
			_icon_height = 40
		else:
			_icon_height = 32

func __on_joy_connection_changed(device: int, connected: bool):
	if device == _main_joypad_device and not connected:
		_main_joypad_device = null
		prefer_joypad_over_keyboard = false
	elif _main_joypad_device == null and connected:
		_main_joypad_device = device
		prefer_joypad_over_keyboard = true
		detected_joypad_brand = parse_device_brand_from_name(
			Input.get_joy_name(device))


func get_preferred_button_name(input_action_name):
	for ev in InputMap.get_action_list(input_action_name):
		if ev is InputEventKey and not prefer_joypad_over_keyboard:
			var button_name = ev.as_text()
			if ev.physical_scancode != 0:
				button_name = OS.get_scancode_string(ev.physical_scancode)
			return button_name
		if ev is InputEventJoypadButton and prefer_joypad_over_keyboard:
			return get_preferred_button_name_from_index(ev.button_index)
	return null

func get_preferred_button_bbcode(input_action_name):
	for ev in InputMap.get_action_list(input_action_name):
		if ev is InputEventKey and not prefer_joypad_over_keyboard:
			var button_name = ev.as_text()
			if ev.physical_scancode != 0:
				button_name = OS.get_scancode_string(ev.physical_scancode)
			var button_bbcode = "[b]%s[/b]" % [button_name]
			return button_bbcode
		if ev is InputEventJoypadButton and prefer_joypad_over_keyboard:
			var button_icon_name = get_preferred_button_icon_name_from_index(
				ev.button_index)
			if button_icon_name != null:
				var icon_path = "res://assets/icons/buttons/%s.png" % [
					button_icon_name]
				return "[i][img=%s]%s[/img][/i]" % [_icon_height, icon_path]
			var button_name = get_preferred_button_name_from_index(
				ev.button_index)
			var button_bbcode = "[u]%s[/u]" % [button_name]
			return button_bbcode
	return null

func get_preferred_button_icon_name(input_action_name):
	for ev in InputMap.get_action_list(input_action_name):
		if ev is InputEventKey and not prefer_joypad_over_keyboard:
			return null
		if ev is InputEventJoypadButton and prefer_joypad_over_keyboard:
			return get_preferred_button_icon_name_from_index(ev.button_index)
	return null

func get_preferred_button_name_from_index(button_index: int):
	var brand = preferred_joypad_brand
	if brand == null:
		brand = detected_joypad_brand
	match brand:
		JoypadBrand.Sony:
			return get_sony_button_name_from_index(button_index)
		_:
			return get_default_button_name_from_index(button_index)

func get_default_button_name_from_index(button_index: int):
	match button_index:
		JOY_XBOX_A:
			return "A"
		JOY_XBOX_B:
			return "B"
		JOY_XBOX_X:
			return "X"
		JOY_XBOX_Y:
			return "Y"
		JOY_L:
			return "LB"
		JOY_R:
			return "RB"
		JOY_L2:
			return "LT"
		JOY_R2:
			return "RT"
		JOY_L3:
			return "LS"
		JOY_R3:
			return "RS"
		JOY_DPAD_UP:
			return "Up"
		JOY_DPAD_DOWN:
			return "Down"
		JOY_DPAD_LEFT:
			return "Left"
		JOY_DPAD_RIGHT:
			return "Right"
		_:
			return "Button%s" % [button_index]

func get_sony_button_name_from_index(button_index: int):
	match button_index:
		JOY_SONY_X:
			return "Cross"
		JOY_SONY_CIRCLE:
			return "Circle"
		JOY_SONY_SQUARE:
			return "Square"
		JOY_SONY_TRIANGLE:
			return "Triangle"
		JOY_L:
			return "L1"
		JOY_R:
			return "R1"
		JOY_L2:
			return "L2"
		JOY_R2:
			return "R2"
		JOY_L3:
			return "L3"
		JOY_R3:
			return "R3"
		_:
			return get_default_button_name_from_index(button_index)

func get_preferred_button_icon_name_from_index(button_index: int):
	var brand = preferred_joypad_brand
	if brand == null:
		brand = detected_joypad_brand
	match brand:
		JoypadBrand.Sony:
			return get_sony_button_icon_name_from_index(button_index)
		_:
			return get_default_button_icon_name_from_index(button_index)

func get_default_button_icon_name_from_index(button_index: int):
	match button_index:
		JOY_XBOX_A:
			return "xbox_a"
		JOY_XBOX_B:
			return "xbox_b"
		JOY_XBOX_X:
			return "xbox_x"
		JOY_XBOX_Y:
			return "xbox_y"
		JOY_L:
			return "xbox_lb"
		JOY_R:
			return "xbox_rb"
		JOY_L2:
			return "xbox_lt"
		JOY_R2:
			return "xbox_rt"
		JOY_L3:
			return "xbox_ls"
		JOY_R3:
			return "xbox_rs"
		_:
			return null

func get_sony_button_icon_name_from_index(button_index: int):
	match button_index:
		JOY_SONY_X:
			return "sony_cross"
		JOY_SONY_CIRCLE:
			return "sony_circle"
		JOY_SONY_SQUARE:
			return "sony_square"
		JOY_SONY_TRIANGLE:
			return "sony_triangle"
		JOY_L:
			return "sony_l1"
		JOY_R:
			return "sony_r1"
		JOY_L2:
			return "sony_l2"
		JOY_R2:
			return "sony_r2"
		JOY_L3:
			return "sony_l3"
		JOY_R3:
			return "sony_r3"
		_:
			return null

func parse_device_brand_from_name(name):
	if name == null:
		return null
	var regex = RegEx.new()
	var pattern = "(?<sony>[Ss]ony|SONY|[Pp]laystation|PLAYSTATION)"
	regex.compile(pattern)
	var result = regex.search(name)
	if result != null:
		if not result.get_string("sony").empty():
			return JoypadBrand.Sony
	return JoypadBrand.Default
