extends Node2D
const names = ["Blair","Cheryl","Diana","Erica","Faye","Gina","Heather","Ivy","Brad","Chad","Dylan","Evan","Frank","Gavin","Hunter","Ian"]
const letters = "BCDEFGHIKLNOPQRSTUVWXYZ"
func _ready():
	if Autoscores.player_name=="Anonymous":
		$Hints.hide()
		$"%LineEdit".text = names[randi()%len(names)] + " " + letters[randi()%len(letters)] + "."
	else:
		$Hints.show()
		$"%LineEdit".text = Autoscores.player_name
	$"%ButtonNext".connect("pressed", self, "do_play")

func _process(_delta):
	if Autoscores.loaded:
		$NoteLoading.hide()
	else:
		$NoteLoading.show()
	$"%RichTextLabel".bbcode_text = Autoscores.high_score_table


func do_play():
	ClutterManager.play("res://assets/sfx/turn_page.wav")
	Autoscores.set_player_name($"%LineEdit".text)
	get_tree().change_scene("res://desktop2.tscn")
