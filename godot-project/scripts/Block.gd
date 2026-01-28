extends Node2D

const MOVE_DISTANCE := 600.0
@export var move_speed: float = 200.0
var move_direction := 1
var is_moving := true
var dropped := false

signal block_dropped(alignment_offset: float)

func _physics_process(delta: float) -> void:
    if is_moving:
        position.x += move_direction * move_speed * delta
        if position.x > MOVE_DISTANCE:
            move_direction = -1
        elif position.x < 0:
            move_direction = 1

func drop():
    if dropped:
        return
    dropped = true
    is_moving = false
    # Calculate alignment offset for scoring
    # Perfect alignment means offset near 0.
    var top_block = get_parent().get_node_or_null("TopBlock")
    if top_block == null:
        emit_signal("block_dropped", 0.0)
        return
    var offset = position.x - top_block.position.x
    emit_signal("block_dropped", offset)