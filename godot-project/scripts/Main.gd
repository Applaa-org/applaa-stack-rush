extends Node2D

@onready var block_scene: PackedScene = preload("res://scenes/Block.tscn")
@onready var blocks_container: Node2D = $BlocksContainer
@onready var height_label: Label = $HUD/HeightLabel
@onready var speed_label: Label = $HUD/SpeedLabel
@onready var current_score_label: Label = $HUD/CurrentScoreLabel
@onready var high_score_label: Label = $HUD/HighScoreLabel

var current_block: Node2D = null
var block_stack: Array = []
var block_speed: float = 200.0
var level: int = 1
var height: int = 0

func _ready():
    _init_game()
    Global.connect("high_score_updated", Callable(self, "_update_high_score"))
    _update_high_score(Global.high_score)

func _init_game():
    # Reset state
    block_stack.clear()
    level = 1
    height = 0
    block_speed = 200.0
    score = 0
    # Clear blocks container children
    for child in blocks_container.get_children():
        child.queue_free()
    spawn_block()

func spawn_block():
    current_block = block_scene.instantiate()
    current_block.position = Vector2(0, 600 - height * 40)
    current_block.move_speed = block_speed
    current_block.name = "CurrentBlock"
    blocks_container.add_child(current_block)
    current_block.connect("block_dropped", Callable(self, "_on_block_dropped"))

func _on_block_dropped(offset):
    # Calculate alignment quality: perfect alignment means offset near 0
    var alignment = abs(offset)
    if alignment > 100:
        # Misaligned => defeat screen
        Global.score = height  # Score is number of stacked blocks
        Global.save_score()
        get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")
        return

    # Align block x position based on previous block with the offset
    if block_stack.size() > 0:
        var top_block = block_stack[block_stack.size() - 1]
        current_block.position.x = top_block.position.x + offset
    # Add current block to stack
    current_block.name = "StackBlock_%d" % height
    block_stack.append(current_block)

    # Update game values
    height += 1
    Global.score = height
    Global.save_progress({"height": height, "level": level})
    _update_score()
    _update_height_meter()
    _update_speed_indicator()

    # Prepare next block speed increase
    level += 1
    block_speed = min(1200.0, block_speed * 1.1) # increase speed by 10% capped

    # Spawn next block
    spawn_block()

func _update_score():
    current_score_label.text = "Score: %d" % Global.score

func _update_height_meter():
    height_label.text = "Height: %d" % height

func _update_speed_indicator():
    speed_label.text = "Speed: %.0f" % block_speed

func _update_high_score(new_high_score: int):
    if high_score_label:
        high_score_label.text = "Best: %d" % new_high_score

func _input(event):
    if event is InputEventScreenTouch or (event is InputEventKey and event.pressed and event.scancode == Key.SPACE):
        if current_block and current_block.is_moving:
            current_block.drop()