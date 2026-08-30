extends Node

# Autoload singleton: persists progress between runs and holds shared game data.

signal gems_changed(total: int)

const SAVE_PATH := "user://savegame.cfg"

var best_score: int = 0
var total_gems: int = 0
var run_gems: int = 0
var run_score: int = 0

var skins: Array = [
	{"id": "fuego", "name": "Fuego", "color": Color(0.95, 0.35, 0.25), "cost": 0},
	{"id": "hielo", "name": "Hielo", "color": Color(0.4, 0.75, 0.95), "cost": 20},
	{"id": "bosque", "name": "Bosque", "color": Color(0.35, 0.75, 0.35), "cost": 20},
	{"id": "tormenta", "name": "Tormenta", "color": Color(0.6, 0.45, 0.9), "cost": 35},
	{"id": "dorado", "name": "Dorado", "color": Color(0.95, 0.8, 0.2), "cost": 50},
]
var unlocked_skins: Array = ["fuego"]
var selected_skin: String = "fuego"

func _ready() -> void:
	_setup_input()
	_load()

func _setup_input() -> void:
	if InputMap.has_action("tap"):
		return
	InputMap.add_action("tap")

	var mouse_ev := InputEventMouseButton.new()
	mouse_ev.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("tap", mouse_ev)

	var touch_ev := InputEventScreenTouch.new()
	touch_ev.pressed = true
	InputMap.action_add_event("tap", touch_ev)

	var key_ev := InputEventKey.new()
	key_ev.keycode = KEY_SPACE
	InputMap.action_add_event("tap", key_ev)

func start_run() -> void:
	run_gems = 0
	run_score = 0

func add_score() -> void:
	run_score += 1

func add_gem() -> void:
	run_gems += 1
	total_gems += 1
	gems_changed.emit(total_gems)

func end_run() -> void:
	if run_score > best_score:
		best_score = run_score
	_save()

func can_buy(skin_id: String) -> bool:
	for s in skins:
		if s["id"] == skin_id:
			return total_gems >= s["cost"] and not unlocked_skins.has(skin_id)
	return false

func buy_skin(skin_id: String) -> bool:
	for s in skins:
		if s["id"] != skin_id:
			continue
		if unlocked_skins.has(skin_id):
			return false
		if total_gems < s["cost"]:
			return false
		total_gems -= s["cost"]
		unlocked_skins.append(skin_id)
		gems_changed.emit(total_gems)
		_save()
		return true
	return false

func select_skin(skin_id: String) -> void:
	if unlocked_skins.has(skin_id):
		selected_skin = skin_id
		_save()

func get_selected_color() -> Color:
	for s in skins:
		if s["id"] == selected_skin:
			return s["color"]
	return Color.WHITE

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "best_score", best_score)
	cfg.set_value("progress", "total_gems", total_gems)
	cfg.set_value("progress", "unlocked_skins", unlocked_skins)
	cfg.set_value("progress", "selected_skin", selected_skin)
	cfg.save(SAVE_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_score = cfg.get_value("progress", "best_score", 0)
		total_gems = cfg.get_value("progress", "total_gems", 0)
		unlocked_skins = cfg.get_value("progress", "unlocked_skins", ["fuego"])
		selected_skin = cfg.get_value("progress", "selected_skin", "fuego")
