extends Node2D

# A pair of magic-crystal pillars with a gap to fly through, plus a score zone
# and optionally a gem in the middle of the gap. Moves left at a set speed.
# Visuals: a tileable crystal texture stretched to each pillar's height, so
# the art always matches the collision rectangles exactly.

const PILLAR_WIDTH := 70.0
const SCREEN_HEIGHT := 1280.0
const PILLAR_TEXTURE := preload("res://assets/sprites/pillar_crystal.png")
const GEM_TEXTURE := preload("res://assets/sprites/gem.png")

var gap_y: float = 400.0
var gap_size: float = 320.0
var speed: float = 220.0
var has_gem: bool = false
var scored: bool = false

func setup(p_gap_y: float, p_gap_size: float, p_speed: float, p_has_gem: bool) -> void:
	gap_y = p_gap_y
	gap_size = p_gap_size
	speed = p_speed
	has_gem = p_has_gem
	_build_colliders()
	_build_visuals()

func _build_colliders() -> void:
	var top_height: float = max(gap_y - gap_size / 2.0, 1.0)
	var top_area := Area2D.new()
	top_area.collision_layer = 2
	top_area.collision_mask = 0
	top_area.add_to_group("pillar")
	var top_shape := CollisionShape2D.new()
	var top_rect := RectangleShape2D.new()
	top_rect.size = Vector2(PILLAR_WIDTH, top_height)
	top_shape.shape = top_rect
	top_shape.position = Vector2(0, top_height / 2.0)
	top_area.add_child(top_shape)
	add_child(top_area)

	var bottom_top: float = gap_y + gap_size / 2.0
	var bottom_height: float = max(SCREEN_HEIGHT - bottom_top, 1.0)
	var bottom_area := Area2D.new()
	bottom_area.collision_layer = 2
	bottom_area.collision_mask = 0
	bottom_area.add_to_group("pillar")
	var bottom_shape := CollisionShape2D.new()
	var bottom_rect := RectangleShape2D.new()
	bottom_rect.size = Vector2(PILLAR_WIDTH, bottom_height)
	bottom_shape.shape = bottom_rect
	bottom_shape.position = Vector2(0, bottom_top + bottom_height / 2.0)
	bottom_area.add_child(bottom_shape)
	add_child(bottom_area)

	var score_area := Area2D.new()
	score_area.collision_layer = 4
	score_area.collision_mask = 0
	score_area.add_to_group("score_zone")
	var score_shape := CollisionShape2D.new()
	var score_rect := RectangleShape2D.new()
	score_rect.size = Vector2(16, gap_size)
	score_shape.shape = score_rect
	score_shape.position = Vector2(PILLAR_WIDTH / 2.0 + 8, gap_y)
	score_area.add_child(score_shape)
	score_area.set_meta("obstacle", self)
	add_child(score_area)

func _build_visuals() -> void:
	var top_height: float = max(gap_y - gap_size / 2.0, 1.0)
	var top_visual := NinePatchRect.new()
	top_visual.texture = PILLAR_TEXTURE
	top_visual.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	top_visual.position = Vector2(-PILLAR_WIDTH / 2.0, 0)
	top_visual.size = Vector2(PILLAR_WIDTH, top_height)
	top_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_visual)

	var bottom_top: float = gap_y + gap_size / 2.0
	var bottom_height: float = max(SCREEN_HEIGHT - bottom_top, 1.0)
	var bottom_visual := NinePatchRect.new()
	bottom_visual.texture = PILLAR_TEXTURE
	bottom_visual.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	bottom_visual.position = Vector2(-PILLAR_WIDTH / 2.0, bottom_top)
	bottom_visual.size = Vector2(PILLAR_WIDTH, bottom_height)
	bottom_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom_visual)

	if has_gem:
		var gem_sprite := Sprite2D.new()
		gem_sprite.texture = GEM_TEXTURE
		gem_sprite.position = Vector2(0, gap_y)
		add_child(gem_sprite)

func _physics_process(delta: float) -> void:
	position.x -= speed * delta

func is_off_screen() -> bool:
	return position.x < -PILLAR_WIDTH - 20
