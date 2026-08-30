extends Node2D

# Simple procedurally-drawn sky with slow-drifting clouds. No image assets required.

const SCREEN_WIDTH := 720.0
const SCREEN_HEIGHT := 1280.0

var cloud_positions: Array = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	for i in range(6):
		cloud_positions.append(Vector2(
			rng.randf_range(0, SCREEN_WIDTH),
			rng.randf_range(80, SCREEN_HEIGHT * 0.5)
		))

func _process(delta: float) -> void:
	for i in range(cloud_positions.size()):
		cloud_positions[i].x -= 18.0 * delta
		if cloud_positions[i].x < -80:
			cloud_positions[i].x = SCREEN_WIDTH + 80
			cloud_positions[i].y = rng.randf_range(80, SCREEN_HEIGHT * 0.5)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color(0.55, 0.78, 0.95))
	draw_rect(Rect2(Vector2(0, SCREEN_HEIGHT * 0.7), Vector2(SCREEN_WIDTH, SCREEN_HEIGHT * 0.3)), Color(0.4, 0.65, 0.85))

	for pos in cloud_positions:
		draw_circle(pos, 34, Color(1, 1, 1, 0.85))
		draw_circle(pos + Vector2(28, 6), 26, Color(1, 1, 1, 0.85))
		draw_circle(pos + Vector2(-26, 8), 24, Color(1, 1, 1, 0.85))

	draw_rect(Rect2(Vector2(0, SCREEN_HEIGHT - 60), Vector2(SCREEN_WIDTH, 60)), Color(0.3, 0.55, 0.3))
