extends Node2D

func _ready() -> void:
	add_to_group("pancakes")
	#auto bounces on creation
	create_tween().tween_property(self, "position:y", position.y + 300, 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _play_animation(anim: String):
	$AnimatedSprite2D.play(anim)
