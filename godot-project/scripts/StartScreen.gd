extends Control

@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var player_name_input: LineEdit = $VBoxContainer/PlayerNameInput
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready():
    # Initialize high score to 0 immediately (visible)
    high_score_label.text = "High Score: 0"
    high_score_label.visible = true
    # Connect buttons
    start_button.pressed.connect(_on_start_pressed)
    close_button.pressed.connect(_on_close_pressed)
    # Connect signal from Global for high score update
    Global.connect("high_score_updated", Callable(self, "_update_high_score"))
    # Pre-fill player name if available
    player_name_input.text = Global.player_name
    # Listen for messages from JavaScript
    set_process(true)

func _update_high_score(new_high_score: int) -> void:
    high_score_label.text = "High Score: %d" % new_high_score

func _on_start_pressed() -> void:
    # Save player name to global and send save data message
    Global.player_name = player_name_input.text.strip()
    Global.save_progress({"lastPlayerName": Global.player_name})
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed() -> void:
    get_tree().quit()

func _process(delta: float) -> void:
    # Listen for applaa-game-data-loaded message from JS
    if Engine.is_editor_hint():
        return # Don't run in editor
    for msg in JavaScriptBridge.get_messages():
        if typeof(msg) != TYPE_DICTIONARY:
            continue
        if msg.has("type") and msg["type"] == "applaa-game-data-loaded":
            var data = msg.get("data", null)
            if data:
                Global._on_applaa_data_loaded(data)