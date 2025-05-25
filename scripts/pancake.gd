extends CharacterBody2D

var dragging = false
var offset = Vector2.ZERO #makes sure pancake plate stays on mouse

var stack = 0 #keep track of stack

# var topping = "nothing" - future implementation ?

func _ready():
	pass

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
		else:
			dragging = false
			create_tween().tween_property(self, "position", Vector2(375, 515), 0.85).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _process(delta):
	var screen = get_viewport().get_visible_rect()
	
	#scale to give sense of depth
	if (position.y <= screen.size.y / 3 * 2):
		$sprites.scale = Vector2(0.5, 0.5)
	else:
		$sprites.scale = Vector2(1, 1)
	
	if dragging:
		#stay on screen
		var pos = get_global_mouse_position() + offset
		var collision = $CollisionShape2D
		var hw = collision.shape.extents.x
		var hh = collision.shape.extents.y 	
		pos.x = clamp(pos.x, screen.position.x + hw, screen.position.x + screen.size.x  - hw)
		pos.y = clamp(pos.y, screen.position.y + hh, screen.position.y + screen.size.y - hh)

		#update pos
		position = pos
