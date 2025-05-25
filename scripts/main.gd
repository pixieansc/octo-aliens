extends Node2D

var cooking = preload("res://scenes/cooking.tscn")
var pancake = preload("res://scenes/pancake.tscn")
var customer = preload("res://scenes/customer.tscn")

var rng = RandomNumberGenerator.new() # to randomly generate customers
var colors = ["red", "blue", "green", "pink", "indigo", "yellow"]
var locations = [Vector2(200, 320), Vector2(450, 350), Vector2(700, 350), Vector2(950, 320)]

var dir = [-1, 1] #for pancake offset

#end scores
@onready var happy_customers = 0
@onready var unhappy_customers = 0
@onready var burnt_pancakes = 0

#difficulty ? could affect these timer effects
var check_space_time = 5 #how often to check for space for new customers
@onready var timer = $ui/game_timer
var game_time = 300

func _ready() -> void:
	create_customer() # creates first customer
	
	#creates spawn customer timer
	var check_space = Timer.new()
	check_space.wait_time = 5.0
	check_space.one_shot = false #auto repeats
	check_space.autostart = true #auto starts
	add_child(check_space)
	check_space.timeout.connect(_on_check_space_timer_timeout)
	
	#starts game timer
	timer.start(game_time)

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		new_pancake()
		
	$ui/timer.text = "time left: %02d:%02d" % [int(timer.time_left / 60), int(timer.time_left) % 60]

#cooking mini game - raw pancake appears
func _on_new_pancake_pressed() -> void:
	#hide button
	$new_pancake.set_deferred("visible",  false)
	$new_pancake.set_deferred("disabled", true)
	
	#animate
	$pan/pan_anim.play("cooking")
	var new_cake = pancake.instantiate()
	new_cake._play_animation("raw") #chooses animation
	new_cake.position = Vector2($pan/StaticBody2D/CollisionShape2D.position.x ,
	$pan/StaticBody2D/CollisionShape2D.position.y - 200) #creates it above the plate 	
	$pan.add_child(new_cake) #so that it can bounce below !
	create_tween().tween_property(new_cake, "position:y", $pan/StaticBody2D/CollisionShape2D.position.y - 10, 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	#initiate cooking game
	var c = cooking.instantiate()	
	c.position.x = 980
	c.position.y = 475
	add_child(c)
	c.scale = Vector2(0.3, 0.3)
	create_tween().tween_property(c, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	c.destroyed.connect(_on_pancake_end)

#cooking mini game end 
func _on_pancake_end(cooked: bool):
	#explode
	if not cooked:
		$pan/explosion.play("default")
	
	$pan/pan_anim.play("idle")
	$new_pancake.set_deferred("visible",  true)
	$new_pancake.set_deferred("disabled", false)
	
	for child in $pan.get_children():
		if child.is_in_group("pancakes"):
			child.queue_free()
	
	if cooked:
		new_pancake()
	else:
		burnt_pancakes += 1

#new cooked pancake appear		
func new_pancake():
	$plate.stack += 1
	var new_cake = pancake.instantiate()

	new_cake._play_animation("cooked") #chooses animation
	new_cake.position = Vector2(+ dir[$plate.stack % 2] * 6,
	- 300 - (30 * $plate.stack)) #creates it above the plate 	
	$plate/sprites.add_child(new_cake) 

	$plate/CollisionShape2D.shape.size.y += 30
	$plate/CollisionShape2D.position.y -= 12 #edits collision shape to inclue new pancake
	
#trash pancake order func !!
func _on_trash_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		clear_plate()

#clears plate
func clear_plate():
	
	$plate.stack = 0
	$plate/CollisionShape2D.shape.size.y = 63
	$plate/CollisionShape2D.position.y = -0.5
	
	for child in $plate/sprites.get_children():
		if child.is_in_group("pancakes"):
			child.queue_free()

func _on_check_space_timer_timeout():
	if locations.size() >= 1:
		create_customer()

#create unique customer (keeps track of what customers are on screen)
func create_customer():
	#makes sure each customer on screen is unique
	var col = colors[rng.randi_range(0, colors.size() - 1)]
	colors.erase(col)
	var loc = locations[rng.randi_range(0, locations.size() - 1)]
	locations.erase(loc)

	#creates customer object
	var new_customer = customer.instantiate()
	new_customer._create(col, loc)
	add_child(new_customer)
	move_child(new_customer, 1)
	new_customer.destroyed.connect(customer_leave)
	

#signal emitted when customer leaves shop
func customer_leave(color: String, location: Vector2, happy: bool):
	colors.append(color)
	locations.append(location)
	
	if happy:
		happy_customers += 1
		$ui/happy.text = "satisfied customers: %d" % happy_customers
	else:
		unhappy_customers += 1
