extends Node2D

# Orchestrates game state (menu / playing / game over / shop), spawns obstacles,
# and wires the dragon + UI screens together.

const SCREEN_WIDTH := 720.0
const SCREEN_HEIGHT := 1280.0

const DRAGON_SCRIPT := preload("res://scripts/Dragon.gd")
const OBSTACLE_SCRIPT := preload("res://scripts/Obstacle.gd")
const BACKGROUND_SCRIPT := preload("res://scripts/Background.gd")
const HUD_SCRIPT := preload("res://scripts/HUD.gd")
const MENU_SCRIPT := preload("res://scripts/MainMenu.gd")
const GAMEOVER_SCRIPT := preload("res://scripts/GameOver.gd")
const SHOP_SCRIPT := preload("res://scripts/Shop.gd")

enum State { MENU, PLAYING, GAME_OVER, SHOP }

var state: int = State.MENU
var dragon
var obstacles: Array = []
var spawn_timer: float = 0.0
var spawn_interval: float = 1.6
var base_speed: float = 240.0
var base_gap: float = 340.0
var rng := RandomNumberGenerator.new()

var background
var hud
var main_menu
var game_over_screen
var shop_screen

func _ready() -> void:
	rng.randomize()

	background = BACKGROUND_SCRIPT.new()
	add_child(background)

	dragon = DRAGON_SCRIPT.new()
	dragon.position = Vector2(SCREEN_WIDTH * 0.3, SCREEN_HEIGHT * 0.5)
	dragon.died.connect(_on_dragon_died)
	dragon.passed_zone.connect(_on_dragon_passed_zone)
	add_child(dragon)

	hud = HUD_SCRIPT.new()
	add_child(hud)

	main_menu = MENU_SCRIPT.new()
	main_menu.play_pressed.connect(_start_game)
	main_menu.shop_pressed.connect(_open_shop)
	add_child(main_menu)

	game_over_screen = GAMEOVER_SCRIPT.new()
	game_over_screen.retry_pressed.connect(_start_game)
	game_over_screen.menu_pressed.connect(_go_to_menu)
	add_child(game_over_screen)

	shop_screen = SHOP_SCRIPT.new()
	shop_screen.closed.connect(_go_to_menu)
	add_child(shop_screen)

	_go_to_menu()

func _unhandled_input(event: InputEvent) -> void:
	if state == State.PLAYING and event.is_action_pressed("tap"):
		dragon.flap()

func _go_to_menu() -> void:
	state = State.MENU
	_clear_obstacles()
	dragon.reset(Vector2(SCREEN_WIDTH * 0.3, SCREEN_HEIGHT * 0.5))
	dragon.set_physics_process(false)

	hud.hide()
	game_over_screen.hide()
	shop_screen.hide()
	main_menu.refresh(GameState.best_score)
	main_menu.show()

func _open_shop() -> void:
	state = State.SHOP
	main_menu.hide()
	shop_screen.refresh()
	shop_screen.show()

func _start_game() -> void:
	state = State.PLAYING
	_clear_obstacles()
	GameState.start_run()
	dragon.reset(Vector2(SCREEN_WIDTH * 0.3, SCREEN_HEIGHT * 0.5))
	dragon.set_physics_process(true)

	spawn_timer = 0.0
	spawn_interval = 1.6

	main_menu.hide()
	game_over_screen.hide()
	shop_screen.hide()
	hud.show()
	hud.update_score(0)
	hud.update_gems(GameState.total_gems)

func _process(delta: float) -> void:
	if state != State.PLAYING:
		return

	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_obstacle()
		spawn_timer = spawn_interval

	for obstacle in obstacles.duplicate():
		if obstacle.is_off_screen():
			obstacles.erase(obstacle)
			obstacle.queue_free()

func _spawn_obstacle() -> void:
	var difficulty: float = clamp(GameState.run_score / 12.0, 0.0, 1.0)
	var gap: float = lerp(base_gap, base_gap * 0.72, difficulty)
	var speed: float = lerp(base_speed, base_speed * 1.5, difficulty)
	spawn_interval = lerp(1.6, 1.05, difficulty)

	var margin: float = 160.0
	var gap_y: float = rng.randf_range(margin + gap / 2.0, SCREEN_HEIGHT - margin - gap / 2.0)
	var has_gem: bool = rng.randf() < 0.5

	var obstacle = OBSTACLE_SCRIPT.new()
	obstacle.position = Vector2(SCREEN_WIDTH + 60, 0)
	obstacle.setup(gap_y, gap, speed, has_gem)
	add_child(obstacle)
	obstacles.append(obstacle)

func _clear_obstacles() -> void:
	for obstacle in obstacles:
		obstacle.queue_free()
	obstacles.clear()

func _on_dragon_passed_zone(area: Area2D) -> void:
	var obstacle = area.get_meta("obstacle", null)
	if obstacle == null or obstacle.scored:
		return
	obstacle.scored = true

	GameState.add_score()
	hud.update_score(GameState.run_score)

	if obstacle.has_gem:
		GameState.add_gem()
		hud.update_gems(GameState.total_gems)

func _on_dragon_died() -> void:
	state = State.GAME_OVER
	GameState.end_run()
	hud.hide()
	game_over_screen.refresh(GameState.run_score, GameState.best_score, GameState.run_gems)
	game_over_screen.show()
