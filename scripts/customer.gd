extends Node2D

var color
var location
var rng = RandomNumberGenerator.new() 
var orders = ["one", "two", "three", "four", "five"]
var stack_num = 0
# var topping = "implement later ?"
var started = false # if patience timer has been started 

var satisfied = false
var patience = 2500
var spawn_time = 7

signal destroyed(color: String, location: Vector2, happy: bool)

func _ready():
	$Area2D.area_entered.connect(Callable(self, "_on_area_2d_area_entered"), CONNECT_ONE_SHOT)

func _process(delta):
	if started: 
		$time_left.value += delta * 50	# continuously update time_left based on delta
		
		if $time_left.value >= $time_left.max_value:
			started = false
			walk_away(false) #octo walks away 

func _create(col: String, loc: Vector2):
	#chooses color
	color = col
	$AnimatedSprite2D.play(color)
	
	#chooses location
	location = loc
	var pos = loc
	
	if pos.x > 500:
		position = Vector2(-100, pos.y - rng.randi_range(50, 200))
	else:
		position = Vector2(1250, pos.y - rng.randi_range(50, 200))
	
	var tw = create_tween()
	tw.tween_property(self, "position", pos, spawn_time).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(Callable(self, "choose_order"))
	tw.tween_callback(Callable(tw, "kill")) #kill itself

#randomly chooses how many stacks
func choose_order():
	stack_num = rng.randi_range(0, 6) % 5 + 1 #messes with the odds lol 
	$order.play(orders[stack_num - 1])
	$order.visible = true
	$Area2D.set_deferred("monitoring", true) #customer can now take orders !
	
	$time_left.max_value = patience * (1 + stack_num / 5) #sets the patience of each octo alien
	$time_left.visible = true
	started = true #starts timer
	
#check if plate of pancakes enters area
func _on_area_2d_area_entered(area: Area2D) -> void:
	#makes sure the parent is the plate obj
	if area.get_parent() is CharacterBody2D:
		if stack_num == area.get_parent().stack:
			satisfied = true
		
		print(get_parent())
		get_parent().clear_plate() #clears current plate
		walk_away(satisfied)

# actually walk away
func walk_away(happy: bool):
	get_parent().move_child(self, 1)
	
	$Area2D.set_deferred("monitoring", false) #customers can no longer take orders
	$time_left.visible = false #hides patience bar
	
	if happy:
		$order.play("happy")
	else:
		$order.play("unhappy")
		
	var tw = create_tween()
	#actually move away:
	if position.x > 500:
		tw.tween_property(self, "position", Vector2(1300, position.y - rng.randi_range(50, 400)), 4).set_trans(Tween.TRANS_SINE)
	else:
		tw.tween_property(self, "position", Vector2(-100, position.y - rng.randi_range(50, 400)), 4).set_trans(Tween.TRANS_SINE)
		
	tw.tween_callback(kill_self)
	tw.tween_callback(Callable(tw, "kill")) #kill tween as well

# removes self from main tree
func kill_self():
	destroyed.emit(color, location, satisfied)
	get_parent().remove_child(self)
	queue_free()	
