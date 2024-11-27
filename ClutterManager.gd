extends Node

var active = null
var dragging = null
var enabled = true
var first_round = true

var clutter_container = null
var droppables = []
var item_scale = 0.5

func reset():
	active = null
	dragging = null
	clutter_container = null
	droppables = []
	
func disable():
	enabled = false
	if active:
			active.deactivate()

func _unhandled_input(event):
	if not enabled:
		return
	if event is InputEventMouseMotion:
		if active:
			active.deactivate()
			active = null
		if clutter_container:
			var clutter := clutter_container.get_children() as Array
			clutter.invert()
			for i in clutter:
				if i.hovering:
					i.activate()
					active = i
					break
	if active:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				ClutterManager.start_drag(active)
			elif event.button_index == BUTTON_LEFT and not event.pressed:
				ClutterManager.stop_drag(active)
		elif event is InputEventMouseMotion:
			ClutterManager.drag(active, event.relative/item_scale)



func start_drag(item: Node2D):
	if not enabled:
		return
	item.rotation = 0
	var container = item.get_parent()
	container.move_child(item, container.get_child_count())
	dragging = item

func stop_drag(item: Node2D):
	if not enabled:
		return
	var accepted := false
	for i in droppables:
		var j := Rect2(i.rect_position, i.rect_size)
		var mouse_position = get_viewport().get_mouse_position()
		#prints(j, mouse_position, j.has_point(mouse_position))
		if j.has_point(mouse_position):
			if i.accept(item):
				accepted = true
				assign(item, i)
				break
	if not accepted:
		if item.container:
			assign(item, item.container)
	dragging = null
	
func assign(item: Node2D, to: Sorter):
	if item.container:
		item.container.stored.erase(item)
		restack(item.container)
	to.stored.append(item)
	item.container = to
	restack(to)

func restack(to: Sorter):
	var rect := Rect2(to.rect_position, to.rect_size)
	var width = rect.size.x
	var angle = PI / 3
	for idx in len(to.stored):
		to.stored[idx].new_position = rect.get_center()
		if len(to.stored)>1:
			to.stored[idx].new_position += Vector2(width / (len(to.stored)+1) * (idx+1) - width * 0.5, 0)
		if len(to.stored)==1:
			to.stored[idx].new_rotation = rand_range(-1.0, 1.0) * PI * 0.025
		else:
			to.stored[idx].new_rotation = angle / (len(to.stored)+1) * (idx+1) - angle * 0.5
		to.stored[idx].play_tween()


func drag(item: Node2D, relative: Vector2):
	if item == dragging:
		item.translate(relative*item.scale)
		
		

var num_players = 3
var bus = "master"

var all_players = []
var available = []  # The available players.
var queue = []  # The queue of sounds to play.


func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		all_players.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		p.bus = bus
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.volume_db = -2.0
	#p.stream = preload("res://assets/sfx/alex-productions-sexy-sax.mp3")
	p.stream = preload("res://assets/sfx/secret_theme02.wav")
	p.play()
	



func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)
	play_next()
	


func play(sound_path):
	queue.append(sound_path)
	
func stop_all():
	while queue:
		queue.pop_back()
	while sound_queue_:
		sound_queue_.pop_back()
	for i in all_players:
		i.stop()

var sound_queue_ = []
func sound_queue(sound_queue):
	stop_all()
	sound_queue_ = sound_queue
	play_next()
	
func play_next():
	if sound_queue_:
		play(sound_queue_.pop_front())

	
	


func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.empty() and not available.empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
