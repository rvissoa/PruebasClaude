extends Area2D

# Player character: tap to flap, gravity pulls down. Rendered with a 3-frame
# flap animation (assets/sprites/dragon_<skin>_0/1/2.png), one set of frames
# per shop skin. Collision stays a simple circle regardless of skin/frame.

signal died
signal passed_zone(area)

const GRAVITY := 1400.0
const FLAP_IMPULSE := -420.0
const MAX_FALL_SPEED := 700.0
const MAX_RISE_SPEED := -420.0
const SCREEN_HEIGHT := 1280.0

const SPRITE_DIR := "res://assets/sprites/"
const SKIN_IDS := ["fuego", "hielo", "bosque", "tormenta", "dorado"]
const FLAP_FPS := 7.0

const FLAP_SOUND := preload("res://assets/audio/sfx/flap.wav")
const HIT_SOUND := preload("res://assets/audio/sfx/hit.wav")

var velocity_y: float = 0.0
var alive: bool = true
var sprite: AnimatedSprite2D
var flap_player: AudioStreamPlayer
var hit_player: AudioStreamPlayer
var _frames_by_skin: Dictionary = {}

func _ready() -> void:
	collision_layer = 1
	collision_mask = 6

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0
	shape.shape = circle
	add_child(shape)

	_build_sprite_frames()

	sprite = AnimatedSprite2D.new()
	sprite.centered = true
	add_child(sprite)

	flap_player = AudioStreamPlayer.new()
	flap_player.stream = FLAP_SOUND
	add_child(flap_player)

	hit_player = AudioStreamPlayer.new()
	hit_player.stream = HIT_SOUND
	add_child(hit_player)

	_apply_skin(GameState.selected_skin)
	area_entered.connect(_on_area_entered)

func _build_sprite_frames() -> void:
	for skin_id in SKIN_IDS:
		var frames := SpriteFrames.new()
		frames.set_animation_loop("default", true)
		frames.set_animation_speed("default", FLAP_FPS)
		for i in range(3):
			var tex: Texture2D = load("%sdragon_%s_%d.png" % [SPRITE_DIR, skin_id, i])
			frames.add_frame("default", tex)
		_frames_by_skin[skin_id] = frames

func _apply_skin(skin_id: String) -> void:
	if not _frames_by_skin.has(skin_id):
		return
	sprite.sprite_frames = _frames_by_skin[skin_id]
	sprite.play("default")

func reset(start_position: Vector2) -> void:
	position = start_position
	velocity_y = 0.0
	rotation = 0.0
	alive = true
	_apply_skin(GameState.selected_skin)

func flap() -> void:
	if not alive:
		return
	velocity_y = FLAP_IMPULSE
	flap_player.play()

func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity_y = clamp(velocity_y + GRAVITY * delta, MAX_RISE_SPEED, MAX_FALL_SPEED)
	position.y += velocity_y * delta
	rotation = clamp(velocity_y / 500.0, -0.5, 1.1)

	if position.y < 20:
		position.y = 20
		velocity_y = 0.0
	elif position.y > SCREEN_HEIGHT - 20:
		position.y = SCREEN_HEIGHT - 20
		die()

func die() -> void:
	if not alive:
		return
	alive = false
	died.emit()
	sprite.stop()
	hit_player.play()

func _on_area_entered(area: Area2D) -> void:
	if not alive:
		return
	if area.is_in_group("pillar"):
		die()
	elif area.is_in_group("score_zone"):
		passed_zone.emit(area)
