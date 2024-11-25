extends Node2D


var dialog = [
	"Hello, what's up?",
	"Hello #Name, I have a quick question for you.",
	"Do you recall if the person you saw had strawberry hair?",
	"Maybe. I think It was either strawberry or chocolate",
	"Cool, thanks."	
]
var dialog_container = []

signal hangup()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Phone/HangupRect.connect("gui_input", self, "gui_input")
	$Phone/HangupRect.connect("mouse_entered", self, "mouse_entered", [true])
	$Phone/HangupRect.connect("mouse_exited", self, "mouse_entered", [false])
	dialog_container = [
	$Phone/BackBufferCopy/Screen/LineR1, $Phone/BackBufferCopy/Screen/LineL1, $Phone/BackBufferCopy/Screen/LineL2, $Phone/BackBufferCopy/Screen/LineR2, $Phone/BackBufferCopy/Screen/LineL3
	]


func set_person(person: Person):
	var phone_person := $Phone/BackBufferCopy/Screen/PersonHolder/Person as Person
	phone_person.make_from(person)
	$Phone/NameLabel.text = phone_person.person_name
	for i in len(dialog):
		dialog_container[i].text = dialog[i].replace("#Name", person.person_name)
	$Phone/BackBufferCopy/Screen.position = Vector2(0,0)
		
func advance_dialog(question, answer):
	var tween = create_tween()
	$Phone/BackBufferCopy/Screen/LineL2.text=question
	$Phone/BackBufferCopy/Screen/LineR2.text=answer
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Phone/BackBufferCopy/Screen, "position", Vector2(0,-230), 1.0)
	

func mouse_entered(is_hovering):
	if is_hovering:
		#$Phone/Hangup.modulate = Color.yellow
		$Phone/Hangup.rotation = PI/8
	else:
		#$Phone/Hangup.modulate = Color.white
		$Phone/Hangup.rotation = 0
	
	
func gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			prints("hangup")
			emit_signal("hangup")

