extends CanvasLayer

const SAVE_PATH := "user://keybinds.cfg"
const ACTIONS := {
	"move_left": {"label": "Left", "default": KEY_LEFT},
	"move_up": {"label": "Up", "default": KEY_UP},
	"move_right": {"label": "Right", "default": KEY_RIGHT},
	"move_down": {"label": "Down", "default": KEY_DOWN},
	"jump": {"label": "Jump", "default": KEY_SPACE},
	"attack": {"label": "Attack", "default": KEY_A},
}

var waiting_action := ""
var buttons: Dictionary = {}
var panel: Panel

func _ready() -> void:
	_apply_defaults()
	_load_keybinds()
	_build_ui()
	_refresh_buttons()

func _input(event: InputEvent) -> void:
	if waiting_action == "":
		return

	if event is InputEventKey and event.pressed and not event.echo:
		_set_action_key(waiting_action, event.keycode)
		_save_keybinds()
		waiting_action = ""
		_refresh_buttons()
		get_viewport().set_input_as_handled()

func _apply_defaults() -> void:
	for action in ACTIONS.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		_set_action_key(action, ACTIONS[action]["default"])

func _build_ui() -> void:
	var toggle := Button.new()
	toggle.text = "Settings"
	toggle.position = Vector2(16, 16)
	toggle.pressed.connect(_toggle_panel)
	add_child(toggle)

	panel = Panel.new()
	panel.visible = false
	panel.position = Vector2(16, 56)
	panel.size = Vector2(260, 300)
	add_child(panel)

	var list := VBoxContainer.new()
	list.position = Vector2(12, 12)
	list.size = Vector2(236, 276)
	panel.add_child(list)

	var title := Label.new()
	title.text = "Key Settings"
	list.add_child(title)

	for action in ACTIONS.keys():
		var row := HBoxContainer.new()
		list.add_child(row)

		var label := Label.new()
		label.text = ACTIONS[action]["label"]
		label.custom_minimum_size = Vector2(90, 24)
		row.add_child(label)

		var button := Button.new()
		button.custom_minimum_size = Vector2(130, 24)
		button.pressed.connect(_start_rebind.bind(action))
		row.add_child(button)
		buttons[action] = button

	var reset := Button.new()
	reset.text = "Reset Defaults"
	reset.pressed.connect(_reset_defaults)
	list.add_child(reset)

func _toggle_panel() -> void:
	panel.visible = not panel.visible

func _start_rebind(action: String) -> void:
	waiting_action = action
	buttons[action].text = "Press a key..."

func _set_action_key(action: String, keycode: Key) -> void:
	InputMap.action_erase_events(action)
	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action, event)

func _get_action_key(action: String) -> Key:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.keycode
	return KEY_NONE

func _refresh_buttons() -> void:
	for action in ACTIONS.keys():
		var keycode := _get_action_key(action)
		buttons[action].text = OS.get_keycode_string(keycode)

func _save_keybinds() -> void:
	var config := ConfigFile.new()
	for action in ACTIONS.keys():
		config.set_value("keys", action, int(_get_action_key(action)))
	config.save(SAVE_PATH)

func _load_keybinds() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	for action in ACTIONS.keys():
		var keycode := int(config.get_value("keys", action, ACTIONS[action]["default"]))
		_set_action_key(action, keycode as Key)

func _reset_defaults() -> void:
	_apply_defaults()
	_save_keybinds()
	_refresh_buttons()
