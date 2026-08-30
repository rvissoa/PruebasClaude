extends Control

# Score and gem counter shown during gameplay.

var score_label: Label
var gem_label: Label

func _ready() -> void:
	score_label = Label.new()
	score_label.position = Vector2(24, 40)
	score_label.add_theme_font_size_override("font_size", 48)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.add_theme_color_override("font_outline_color", Color.BLACK)
	score_label.add_theme_constant_override("outline_size", 6)
	add_child(score_label)

	gem_label = Label.new()
	gem_label.position = Vector2(24, 100)
	gem_label.add_theme_font_size_override("font_size", 28)
	gem_label.add_theme_color_override("font_color", Color(1, 0.85, 0.25))
	gem_label.add_theme_color_override("font_outline_color", Color.BLACK)
	gem_label.add_theme_constant_override("outline_size", 5)
	add_child(gem_label)

	update_score(0)
	update_gems(GameState.total_gems)

func update_score(value: int) -> void:
	score_label.text = "%d" % value

func update_gems(value: int) -> void:
	gem_label.text = "Gemas: %d" % value
