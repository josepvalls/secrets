extends Node2D
const names = ["Blair","Cheryl","Diana","Erica","Faye","Gina","Heather","Ivy","Brad","Chad","Dylan","Evan","Frank","Gavin","Hunter","Ian"]
const letters = "BCDEFGHIKLNOPQRSTUVWXYZ"
func _ready():
	if ClutterManager.first_round:
		$Hints.hide()
		$"%LineEdit".text = names[randi()%len(names)] + " " + letters[randi()%len(letters)] + "."
	else:
		$Hints.show()
		$"%LineEdit".text = Autoscores.player_name
	$"%ButtonNext".connect("pressed", self, "do_play")

func _process(_delta):
	$"%RichTextLabel".bbcode_text = Autoscores.high_score_table


func do_play():
	Autoscores.set_player_name($"%LineEdit".text)
	get_tree().change_scene("res://desktop2.tscn")
