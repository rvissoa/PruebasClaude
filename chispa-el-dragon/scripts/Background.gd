extends Node2D

# Static sky/sea/grass background image with slow-drifting cloud sprites.

const SCREEN_WIDTH := 720.0
const SCREEN_HEIGHT := 1280.0
const SKY_TEXTURE := preload("res://assets/sprites/background_sky.png")
const CLOUD_TEXTURE := preload("res://assets/sprites/cloud.png")

var cloud_positions: Array = []
var cloud_sprites: Array = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	var sky := Sprite2D.new()
	sky.texture = SKY_TEXTURE
	sky.centered = false
	add_child(sky)

	rng.randomize()
	for i in range(6):
		var pos := Vector2(
			rng.randf_range(0, SCREEN_WIDTH),
			rng.randf_range(80, SCREEN_HEIGHT * 0.5)
		)
		cloud_positions.append(pos)

		var cloud_sprite := Sprite2D.new()
		cloud_sprite.texture = CLOUD_TEXTURE
		cloud_sprite.centered = true
		cloud_sprite.position = pos
		add_child(cloud_sprite)
		cloud_sprites.append(cloud_sprite)

func _process(delta: float) -> void:
	for i in range(cloud_positions.size()):
		cloud_positions[i].x -= 18.0 * delta
		if cloud_positions[i].x < -80:
			cloud_positions[i].x = SCREEN_WIDTH + 80
			cloud_positions[i].y = rng.randf_range(80, SCREEN_HEIGHT * 0.5)
		cloud_sprites[i].position = cloud_positions[i]
