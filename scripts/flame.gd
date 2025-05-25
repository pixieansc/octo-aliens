extends Node2D

var min_dist = 50
var max_dist = 125
var dirs = [-1, 1]
var rng = RandomNumberGenerator.new()
var behaviors = [Tween.TRANS_SINE,
	Tween.TRANS_CIRC,
	Tween.TRANS_BACK,
	Tween.TRANS_SPRING,
	Tween.TRANS_BOUNCE,
	Tween.TRANS_ELASTIC,]
var tween_type = behaviors[rng.randi_range(0, behaviors.size() - 1)]

func _ready():
	$flame_anim.play("default")
	_move()

func _move():
	#randomizes direction (-1 or 1) and distance
	var dir = dirs[randi() % 2]
	var dist = randf_range(min_dist, max_dist)
	var duration = randf_range(2, 2.5)

	var target_y = clamp(dir * dist, -123, 123) #clamps it in range
	
	var tw = create_tween()
	tw.tween_property(self, "position:y", target_y, duration).set_trans(tween_type).set_ease(Tween.EASE_OUT)
	tw.tween_callback(Callable(self, "_move"))
