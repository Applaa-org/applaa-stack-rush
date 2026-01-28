extends Control

@onready var final_score_label: Label = $VBoxContainer/FinalScoreLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var new_high_label: Label = $VBoxContainer/NewHighLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready():
    final_score_label.text = "Your Height: %d" % Global.score
    var highscore = max(Global.score, Global.high_score)
    high_score_label.text = "High Score: %d" % highscore
    new_high_label.visible = false
    if Global.score > Global.high_score:
        new_high_label.visible = true
    restart_button.pressed.connect(_on_restart_pressed)
    main_menu_button.pressed.connect(_on_main_menu_pressed)
    close_button.pressed.connect(_on_close_pressed)
    # Save new high score if needed
    if Global.score > Global.high_score:
        Global.high_score = Global.score
        Global.save_score()

func _on_restart_pressed():
    Global.score = 0
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_pressed():
    Global.score = 0
    get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
    get_tree().quit()