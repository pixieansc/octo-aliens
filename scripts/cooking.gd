extends Node2D

var vel_max = 6
var vel = 0
var acc = 0.3
var grav = 0.2  
var bounce = 0.8
var cooked = false

signal destroyed(cooked: bool)

func _ready():
	pass
		
func _process(delta: float):
	
	#calculates vel
	if Input.is_action_pressed("space_bar"):
		vel = clamp(vel - acc, -vel_max, vel_max + 0.5)
	else:
		vel = clamp(vel + grav, -vel_max, vel_max + 0.5)
	
	#calculates pos
	var new_pos = clamp($control.position.y + vel, -246, 0)
	
	if new_pos == 0:
		vel *= -bounce
	elif new_pos <= -246:
		vel = 0
	
	#updates pos
	$control.position.y = new_pos
	
	if $control/Area2D.overlaps_area($flame/Area2D):
		$progress.value = min($progress.value + 100 * delta, 500)
		if $progress.value == 500:
			cooked = true
			stop_game()
	else:
		$progress.value = max($progress.value - 150 * delta, 0)
		if $progress.value == 0:
			stop_game()


func stop_game():
	$progress.value = 100
	destroyed.emit(cooked)  #let parent know that the game is ending
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_callback(kill_self)
	
func kill_self():
	get_parent().remove_child(self)
	queue_free()	
		
		
