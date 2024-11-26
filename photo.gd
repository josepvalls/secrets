extends Node2D
class_name DroppableItem

var container = null

var item_name = "potato"

var props = []
var idx = 0
var person_name = ""
var is_called = false

var alibi = []
var answers = []
var answers_neg = []

var new_position = Vector2.ZERO
var new_rotation = 0.0
var tween: SceneTreeTween = null
var hovering = false
func _ready():
	if has_node("BFF"):
		$BFF.hide()
	if has_node("Called"):
		$Called.hide()
	$Area2D.connect("mouse_entered", self, "set_hovering", [true])
	$Area2D.connect("mouse_exited", self, "set_hovering", [false])


func set_hovering(active: bool):
	#prints("set_hovering", self, active)
	hovering = active

func deactivate():
	$Line2D.hide()

func activate():
	$Line2D.show()

	
func play_tween():
	kill_tween()
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", new_position, 0.3)
	tween.tween_property(self, "rotation", new_rotation, 0.3)

func kill_tween():
	if tween:
		tween.kill()
		#position = new_position
		#rotation = new_rotation
	

func make_person():
	if has_node("Person"):
		$Person.make_person(props, idx)
		if has_node("Label"):
			$Label.text = $Person.person_name
		person_name = $Person.person_name
			
func set_additional_props(props_):
	if has_node("Person"):
		$Person.set_additional_props(props_)
		props.append_array(props_)

func make_random_person():
	if has_node("Person"):
		$Person.make_person([randi()%3,randi()%3,randi()%3,randi()%3, randi()%3, randi()%3], randi())
		if has_node("Label"):
			$Label.text = $Person.person_name
		person_name = $Person.person_name

	
