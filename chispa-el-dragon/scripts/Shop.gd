extends Control

signal closed

var rows: Array = []

func _ready() -> void:
	var panel := ColorRect.new()
	panel.position = Vector2.ZERO
	panel.size = Vector2(720, 1280)
	panel.color = Color(0.1, 0.1, 0.2, 0.9)
	add_child(panel)

	var title := Label.new()
	title.text = "Tienda de Dragones"
	title.position = Vector2(140, 100)
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color.WHITE)
	add_child(title)

	var close_button := Button.new()
	close_button.text = "X"
	close_button.position = Vector2(630, 60)
	close_button.custom_minimum_size = Vector2(60, 60)
	close_button.pressed.connect(func(): closed.emit())
	add_child(close_button)

	var y := 220
	for skin in GameState.skins:
		var row := _build_row(skin, y)
		add_child(row)
		rows.append(row)
		y += 170

func _build_row(skin: Dictionary, y: int) -> Control:
	var row := Control.new()
	row.position = Vector2(60, y)

	var swatch_bg := ColorRect.new()
	swatch_bg.color = Color(1, 1, 1, 0.08)
	swatch_bg.size = Vector2(90, 90)
	row.add_child(swatch_bg)

	var swatch := TextureRect.new()
	swatch.texture = load("res://assets/sprites/dragon_%s_1.png" % skin["id"])
	swatch.size = Vector2(90, 90)
	swatch.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(swatch)

	var name_label := Label.new()
	name_label.text = skin["name"]
	name_label.position = Vector2(110, 0)
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	row.add_child(name_label)

	var cost_label := Label.new()
	cost_label.position = Vector2(110, 40)
	cost_label.add_theme_font_size_override("font_size", 20)
	cost_label.add_theme_color_override("font_color", Color(1, 0.85, 0.25))
	row.add_child(cost_label)

	var action_button := Button.new()
	action_button.position = Vector2(400, 10)
	action_button.custom_minimum_size = Vector2(200, 70)
	action_button.pressed.connect(_on_action_pressed.bind(skin["id"]))
	row.add_child(action_button)

	row.set_meta("action_button", action_button)
	row.set_meta("cost_label", cost_label)
	row.set_meta("skin_id", skin["id"])
	row.set_meta("cost", skin["cost"])
	return row

func _on_action_pressed(skin_id: String) -> void:
	if GameState.unlocked_skins.has(skin_id):
		GameState.select_skin(skin_id)
	else:
		GameState.buy_skin(skin_id)
	refresh()

func refresh() -> void:
	for row in rows:
		var skin_id: String = row.get_meta("skin_id")
		var cost: int = row.get_meta("cost")
		var action_button: Button = row.get_meta("action_button")
		var cost_label: Label = row.get_meta("cost_label")

		if GameState.unlocked_skins.has(skin_id):
			cost_label.text = ""
			if GameState.selected_skin == skin_id:
				action_button.text = "EQUIPADO"
				action_button.disabled = true
			else:
				action_button.text = "USAR"
				action_button.disabled = false
		else:
			cost_label.text = "%d gemas" % cost
			action_button.text = "COMPRAR"
			action_button.disabled = GameState.total_gems < cost
