extends Node

@export var game_id: String = "stackrush_8k2m1z7j"  # Unique Identifier for this game

var score: int = 0
var high_score: int = 0
var player_name: String = "Player"
var game_progress: Dictionary = {}

func _ready():
    # Initialize score and load saved data from storage
    score = 0
    high_score = 0
    player_name = "Player"
    game_progress = {}
    _initialize_storage()

func _initialize_storage():
    # Show initial highscore 0 (MANDATORY)
    emit_signal("high_score_updated", high_score)
    # Request data load
    JavaScriptBridge.eval("""
        window.parent.postMessage({
            type: 'applaa-game-load-data',
            gameId: '%s'
        }, '*');
    """ % game_id)

func save_score():
    JavaScriptBridge.eval("""
        window.parent.postMessage({
            type: 'applaa-game-save-score',
            gameId: '%s',
            playerName: '%s',
            score: %d
        }, '*');
    """ % [game_id, player_name, score])

func save_progress(progress_data: Dictionary):
    var json_str = to_json(progress_data)
    JavaScriptBridge.eval("""
        window.parent.postMessage({
            type: 'applaa-game-save-data',
            gameId: '%s',
            data: %s
        }, '*');
    """ % [game_id, json_str])

# Receive messages from JS
func _on_applaa_data_loaded(data: Dictionary) -> void:
    if not data:
        return
    high_score = data.get("highScore", 0)
    player_name = data.get("lastPlayerName", "Player")
    game_progress = data.get("gameProgress", {})
    # Emit signal to update UI
    emit_signal("high_score_updated", high_score)

signal high_score_updated(new_high_score: int)