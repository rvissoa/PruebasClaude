extends Control

signal play_pressed
signal shop_pressed

var best_label: Label

func _ready() -> void:
	var panel := ColorRect.new()
	panel.position = Vector2.ZERO
	panel.size = Vector2(720, 1280)
	panel.color = Color(0, 0, 0, 0.15)
	add_child(panel)

	var title := Label.new()
	title.text = "Chispa\nel Dragon"
	title.position = Vector2(140, 260)
	title.size = Vector2(440, 160)
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color(0.4, 0.1, 0.5))
	title.add_theme_constant_override("outline_size", 8)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	best_label = Label.new()
	best_label.position = Vector2(210, 470)
	best_label.add_theme_font_size_override("font_size", 28)
	best_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(best_label)

	var play_button := Button.new()
	play_button.text = "JUGAR"
	play_button.position = Vector2(210, 620)
	play_button.custom_minimum_size = Vector2(300, 100)
	play_button.add_theme_font_size_override("font_size", 36)
	play_button.pressed.connect(func(): play_pressed.emit())
	add_child(play_button)

	var shop_button := Button.new()
	shop_button.text = "TIENDA"
	shop_button.position = Vector2(210, 750)
	shop_button.custom_minimum_size = Vector2(300, 90)
	shop_button.add_theme_font_size_override("font_size", 30)
	shop_button.pressed.connect(func(): shop_pressed.emit())
	add_child(shop_button)

func refresh(best_score: int) -> void:
	best_label.text = "Mejor puntaje: %d" % best_score
