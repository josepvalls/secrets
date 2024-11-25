extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lines = []
var arrows = []
var header = null
var total_lines = 0
var asked = false
signal question_asked(item)

# Called when the node enters the scene tree for the first time.
func _ready():
	header = $Name
	header.text = ""
	$Arrow.hide()
	for i in 11:
		var line = header.duplicate()
		line.rect_position += Vector2(40,40*(i+2))
		line.connect("gui_input", self, "gui_input_line", [i])
		add_child(line)
		lines.append(line)
		var arrow = $Arrow.duplicate()
		arrow.position += Vector2(0,40*(i+2))
		add_child(arrow)
		arrows.append(arrow)
		
func gui_input_line(event, line_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if asked:
			return
		if total_lines > 0 and line_idx < total_lines:
			asked = true
			clear_lines()
			lines[0].text = "(press the red hangup button to continue)"
			emit_signal("question_asked", line_idx)
	

func clear_lines():
	for i in lines:
		i.text = ""
	for i in arrows:
		i.hide()

func set_text(header_, lines_):
	clear_lines()
	total_lines = len(lines_)
	asked = false
	header.text = header_
	for i in len(lines_):
		lines[i].text = lines_[i]
		arrows[i].show()
	
