extends Control

signal retry_pressed
signal menu_pressed

var score_label: Label
var best_label: Label
var gems_label: Label

func _ready() -> void:
	var panel := ColorRect.new()
	panel.position = Vector2.ZERO
	panel.size = Vector2(720, 1280)
	panel.color = Color(0, 0, 0, 0.35)
	add_child(panel)

	var title := Label.new()
	title.text = "Uy!"
	title.position = Vector2(260, 300)
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color.WHITE)
	add_child(title)

	score_label = Label.new()
	score_label.position = Vector2(230, 420)
	score_label.add_theme_font_size_override("font_size", 34)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(score_label)

	best_label = Label.new()
	best_label.position = Vector2(230, 470)
	best_label.add_theme_font_size_override("font_size", 26)
	best_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	add_child(best_label)

	gems_label = Label.new()
	gems_label.position = Vector2(230, 520)
	gems_label.add_theme_font_size_override("font_size", 26)
	gems_label.add_theme_color_override("font_color", Color(1, 0.85, 0.25))
	add_child(gems_label)

	var retry_button := Button.new()
	retry_button.text = "OTRA VEZ"
	retry_button.position = Vector2(210, 620)
	retry_button.custom_minimum_size = Vector2(300, 100)
	retry_button.add_theme_font_size_override("font_size", 32)
	retry_button.pressed.connect(func(): retry_pressed.emit())
	add_child(retry_button)

	var menu_button := Button.new()
	menu_button.text = "MENU"
	menu_button.position = Vector2(210, 750)
	menu_button.custom_minimum_size = Vector2(300, 90)
	menu_button.add_theme_font_size_override("font_size", 28)
	menu_button.pressed.connect(func(): menu_pressed.emit())
	add_child(menu_button)

func refresh(score: int, best: int, gems: int) -> void:
	score_label.text = "Puntaje: %d" % score
	best_label.text = "Mejor: %d" % best
	gems_label.text = "Gemas ganadas: %d" % gems
