extends ColorRect
class_name Sorter

var stored = []
signal dropped(item, accepted)

export var accept_notes := true
export var max_items := -1

func _gui_input(event):
	if event is InputEventMouseButton:
		prints("InputEventMouseButton", event.pressed)
		
			
	elif event is InputEventMouseMotion:
		pass
		#prints("InputEventMouseMotion")



func accept(item):
	var accepted = true
	if not item.has_node("Person") and not accept_notes:
		accepted = false
		
	if max_items >= 0 and len(stored)>=max_items:
		accepted = false
	
	prints("emit_signal", "dropped", item, accepted)
	emit_signal("dropped", item, accepted)
	
	return accepted
