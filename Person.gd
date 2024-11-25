extends Node2D
class_name Person

onready var skin = [$Vanilla, $Caramel, $Chocolate]
onready var hair = [[$Mandarin, $Mandarin2], [$Liquorice, $Liquorice3], [$Waffle1, $Waffle2]]

#onready var face = [$Happy, $Sad, $Surprised]
onready var accessory = [$Scarf2, $Glasses, $Hat2]
onready var shirt = [$GreenShirt, $OrangeShirt, $BubblegumShirt]
onready var eyes = [$"Eye-recolor1", $"Eye-recolor2", $"Eye-recolor3"]
onready var mouths = [$Mouth1, $Mouth2, $Mouth3, $Mouth4]
onready var earrings = [$Earrings1, $Earrings2, $Earrings3, $Earrings4]
onready var noses = [$Nose1, $Nose2]


const names = [
	#["James","Jack","John","Joe","Julian","Jacob","Jay","Josh","Jordan","Jade","Jess","Jacky","Julia","Janet","Jenny","Janine"],
	["Jordan","Jade","Jess","Jacky","Julia","Janet","Jenny","Janine", "Jo", "Jamie", "Jolene", "Jane", "Jasmine", "Jocelyn"],
	#["Ann","Amelia","Amber","Aurora","Aria","Allison","Abigail","Alice","Alfie","Alex","Aiden","Anthony","Angel","Andrew","Austin","Adam","Andrea"],
	["Ann","Amelia","Amber","Aurora","Aria","Allison","Abigail","Alice","Andrea", "Angela", "Abigail", "Amelie", "Ally", "Amy"],
	#["Max","Michael","Mason","Matthew","Miles","Morgan","Manuel","Melvin","Maria","Mia","Mila","Madison","Micah","Maya","Madelyn","Melody"]
	["Max","Maria","Mia","Mila","Madison","Maya","Madelyn","Melody", "Molly", "Miriam", "Mey", "Megan", "Mery", "Mimi"]
]
const letters = "BCDEFGHIKLNOPQRSTUVWXYZ"
var idx = 0
var person_name = ""
var props = []

func _ready():
	pass

const prop_names = ["skin color", "hair color", "shirt color", "accessories", "eye color", "initial"]
const prop_values = [
	["vanilla", "caramel", "chocolate"],
	["strawberry", "liquorice", "banana"],
	["mint", "orange", "bubblegum"],
	["scarf", "glasses", "hat"],
	["green", "blue", "brown"],
	["j", "a", "m"],
]

func reset_person():
	for i in skin:
		i.hide()
	for i in hair:
		for j in i:
			j.hide()
	for i in accessory:
		i.hide()
	for i in shirt:
		i.hide()
	for i in mouths:
		i.hide()
	for i in earrings:
		i.hide()
	for i in noses:
		i.hide()
	for i in eyes:
		i.hide()		


func make_from(from: Person):
	make_person(from.props, from.idx)
	
static func make_name(props, idx):
	var initial_names = names[props[5]]
	var person_name = initial_names[idx%len(initial_names)]
	person_name += " "
	person_name += letters[idx%len(letters)]
	person_name += "."
	return person_name

static func make_seed(props):
	var random_seed = 1
	for i in props:
		random_seed *= 13
		random_seed += i
	return random_seed


func make_person(props_, idx_):
	idx = idx_
	props = props_
	person_name = make_name(props, idx_)
	reset_person()
	skin[props[0]].show()
	#hair[props[1]].show()
	hair[props[1]][idx_%len(hair[props[1]])].show()
	shirt[props[2]].show()
	accessory[props[3]].show()
	eyes[props[4]].show()
	mouths[idx_ % len(mouths)].show()
	earrings[idx_ % len(earrings)].show()
	noses[idx_ % len(noses)].show()
	
