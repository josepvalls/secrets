extends Node

var save_path = "user://secrets_user_name.json"

func _ready():
	var file = File.new()
	if not file.file_exists(save_path):
		return
	file.open(save_path, File.READ)
	var content = file.get_as_text()
	file.close()
	if content:
		player_name = content

	

var high_score = -10000000
var high_score_formatted = "???"
var high_score_table = "Loading scoreboard..."
var scores = []
var is_highlight = []
var player_name = "Anonymous"
var loaded = false
func do_post(score=-10000000, score_formatted=""):
	pass

func set_player_name(player_name_):
	if player_name_ != "" and not check_in_bad_words(player_name_):
		player_name = player_name_
		var f = File.new()
		f.open(save_path, File.WRITE)
		f.store_string(player_name)
		f.close()

func check_in_bad_words(word):
	for bad_word in get_bad_words():
		if bad_word in word:
			return true
	return false
	
func get_bad_words():
	return """anal
anus
arse
ass
ballsack
balls
bastard
bitch
biatch
bloody
blowjob
blow job
bollock
bollok
boner
boob
bugger
buttplug
clitoris
cunt
damn
dick
dildo
dyke
fag
feck
fellate
fellatio
felching
fuck
fudgepacker
flange
homo
jerk
jizz
knob
labia
nigger
nigga
penis
piss
poop
prick
pube
pussy
queer
scrotum
sex
shit
slut
smegma
spunk
tit
tosser
turd
twat
vagina
wank
whore
wtf""".split("\n")
