extends Node

var running = false
var tensity = 0

var _title_ambience = null
var _title_music = null
var _calm_music = null
var _tense_music = null
var _hum = null

var _on_main_menu =  true
var _on_settings_menu =  true
var _with_hum = true

var _title_ambience_enabled = true
var _title_music_enabled = true
var _calm_music_enabled = true
var _tense_music_enabled = true
var _hum_enabled = true


func run(tracks_resource):
	self.running = true
	var tracks = tracks_resource.instance()
	_title_ambience = tracks.get_node("TitleAmbience")
	_title_music = tracks.get_node("TitleMusic")
	_calm_music = tracks.get_node("CalmMusic")
	_tense_music = tracks.get_node("TenseMusic")
	_hum = tracks.get_node("Hum")
	yield(get_tree(), "idle_frame")
	get_tree().get_root().add_child(tracks)

func enter_main_menu():
	_on_main_menu = true
	_on_settings_menu = false
	_with_hum = true

func enter_settings_menu():
	_on_main_menu = false
	_on_settings_menu = true
	_with_hum = false

func enter_game():
	_on_main_menu = false
	_on_settings_menu = false
	_with_hum = false
	tensity = 0


func _process(delta):
	if not running:
		return
	if _with_hum and _hum_enabled:
		if _on_main_menu:
			update(_hum, -18, delta)
		else:
			update(_hum, -15, delta)
	else:
		update(_hum, null, delta)
	if _on_main_menu and _title_ambience_enabled:
		update(_title_ambience, 10, delta)
	else:
		update(_title_ambience, null, delta)
	if _on_main_menu and _title_music_enabled:
		update(_title_music, -5, delta)
	elif _on_settings_menu and _title_music_enabled:
		update(_title_music, -12, delta)
	else:
		update(_title_music, null, delta)
	if not _on_main_menu and not _on_settings_menu:
		update(_calm_music, 0 - 30 * tensity, delta)
		update(_tense_music, -30 + 30 * tensity, delta)
	else:
		update(_calm_music, null, delta)
		update(_tense_music, null, delta)


func update(track, target, delta):
	if target == null:
		if track.playing:
			if track.volume_db > -30:
				track.volume_db -= 100 * delta
			else:
				track.playing = false
	else:
		if track.playing:
			if track.volume_db > target + 100 * delta:
				track.volume_db -= 100 * delta
			elif track.volume_db < target - 400 * delta:
				track.volume_db += 400 * delta
			elif track.volume_db != target:
				track.volume_db = target
		else:
			track.playing = true
			track.volume_db = -30


func start_hum():
	if not running:
		return
	_with_hum = true

func end_hum():
	if not running:
		return
	_with_hum = false

