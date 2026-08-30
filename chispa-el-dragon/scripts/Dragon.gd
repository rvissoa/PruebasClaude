extends Area2D

# Player character: tap to flap, gravity pulls down, drawn procedurally (no sprite needed).

signal died
signal passed_zone(area)

const GRAVITY := 1400.0
const FLAP_IMPULSE := -420.0
const MAX_FALL_SPEED := 700.0
const MAX_RISE_SPEED := -420.0
const SCREEN_HEIGHT := 1280.0

var velocity_y: float = 0.0
var alive: bool = true
var body_color: Color = Color(0.95, 0.35, 0.25)

func _ready() -> void:
	collision_layer = 1
	collision_mask = 6

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0
	shape.shape = circle
	add_child(shape)

	body_color = GameState.get_selected_color()
	area_entered.connect(_on_area_entered)
	queue_redraw()

func reset(start_position: Vector2) -> void:
	position = start_position
	velocity_y = 0.0
	rotation = 0.0
	alive = true
	body_color = GameState.get_selected_color()
	queue_redraw()

func flap() -> void:
	if not alive:
		return
	velocity_y = FLAP_IMPULSE

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

func _on_area_entered(area: Area2D) -> void:
	if not alive:
		return
	if area.is_in_group("pillar"):
		die()
	elif area.is_in_group("score_zone"):
		passed_zone.emit(area)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 24, body_color)
	draw_circle(Vector2(2, 6), 14, body_color.lightened(0.35))
	draw_circle(Vector2(10, -8), 4, Color.WHITE)
	draw_circle(Vector2(11, -8), 2, Color.BLACK)

	var wing := PackedVector2Array([Vector2(-6, -4), Vector2(-30, -20), Vector2(-14, 10)])
	draw_colored_polygon(wing, body_color.darkened(0.15))

	var snout := PackedVector2Array([Vector2(18, -4), Vector2(34, 0), Vector2(18, 6)])
	draw_colored_polygon(snout, body_color.darkened(0.1))
