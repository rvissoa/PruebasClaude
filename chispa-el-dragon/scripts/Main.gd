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

const POINT_SOUND := preload("res://assets/audio/sfx/point.wav")
const GEM_SOUND := preload("res://assets/audio/sfx/gem.wav")

# Background music is optional: drop a royalty-free .ogg or .mp3 at one of
# these paths and it loops automatically, no code changes needed. Until then
# the game just runs silent on music (SFX still play normally).
const MUSIC_CANDIDATES := [
	"res://assets/audio/music/background.ogg",
	"res://assets/audio/music/background.mp3",
]

enum State { MENU, PLAYING, GAME_OVER, SHOP }

# --- Difficulty tuning ---------------------------------------------------
# GRACE_OBSTACLES: first N gaps always spawn at minimum difficulty, so a kid
#   gets a few easy passes to find the flap rhythm before anything tightens.
# DIFFICULTY_SCORE_CAP: score at which difficulty reaches 100% (gap at its
#   smallest, speed/spawn rate at their fastest). Raised from the original
#   12 so the ramp takes a full short session to max out instead of ~15s.
# GAP_SHRINK_FACTOR / SPEED_MULTIPLIER: how small/fast things get at 100%
#   difficulty, as a fraction/multiple of the base values below. Softened
#   from .72/1.5 so the hardest state is still passable, not punishing.
const GRACE_OBSTACLES: float = 3.0
const DIFFICULTY_SCORE_CAP: float = 30.0
const GAP_SHRINK_FACTOR: float = 0.82
const SPEED_MULTIPLIER: float = 1.3

var state: int = State.MENU
var dragon
var obstacles: Array = []
var spawn_timer: float = 0.0
var spawn_interval: float = 1.6
var base_speed: float = 240.0
var base_gap: float = 380.0
var rng := RandomNumberGenerator.new()

var background
var hud
var main_menu
var game_over_screen
var shop_screen
var point_player: AudioStreamPlayer
var gem_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

func _ready() -> void:
	rng.randomize()

	background = BACKGROUND_SCRIPT.new()
	add_child(background)

	point_player = AudioStreamPlayer.new()
	point_player.stream = POINT_SOUND
	add_child(point_player)

	gem_player = AudioStreamPlayer.new()
	gem_player.stream = GEM_SOUND
	add_child(gem_player)

	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -8.0
	add_child(music_player)
	_start_music_if_available()

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

func _start_music_if_available() -> void:
	for path in MUSIC_CANDIDATES:
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream == null:
				continue
			if "loop" in stream:
				stream.loop = true
			music_player.stream = stream
			music_player.play()
			return

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
	var ramp_score: float = max(0.0, GameState.run_score - GRACE_OBSTACLES)
	var difficulty: float = clamp(ramp_score / DIFFICULTY_SCORE_CAP, 0.0, 1.0)
	var gap: float = lerp(base_gap, base_gap * GAP_SHRINK_FACTOR, difficulty)
	var speed: float = lerp(base_speed, base_speed * SPEED_MULTIPLIER, difficulty)
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
	point_player.play()

	if obstacle.has_gem:
		GameState.add_gem()
		hud.update_gems(GameState.total_gems)
		gem_player.play()

func _on_dragon_died() -> void:
	state = State.GAME_OVER
	GameState.end_run()
	hud.hide()
	game_over_screen.refresh(GameState.run_score, GameState.best_score, GameState.run_gems)
	game_over_screen.show()
