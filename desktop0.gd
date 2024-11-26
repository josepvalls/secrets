extends Node2D

func _ready():
	randomize()
	$Photo1.make_random_person()
	$Photo2.make_random_person()
	$Photo3.make_random_person()
	$Photo4.make_random_person()
	$Photo5.make_random_person()
	$Photo6.make_random_person()
	Autoscores.do_post()
	$"%ButtonNext".connect("pressed", self, "do_play")


func do_play():
	ClutterManager.play("res://assets/sfx/turn_page.wav")
	get_tree().change_scene("res://desktop1.tscn")
