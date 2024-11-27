extends Node2D

export var anim_time = 0.5

var people = []
var liars = []
var suspects = []
var friends = []
var friend_to_person = {}
var cheats = false

var culprit = null
var initial_droppables = []
var initial_notes = []
var intro_pages = []
var intro_pages_idx = 0
var liar_notes_distributed = 0

var current_interrogation = null

onready var timer = $Timer
var elapsed  = 0.0
var penalties = []
var bad_guesses = []
var play_area: Rect2

func _ready():
	
	randomize()
	if "sherlock" in Autoscores.player_name.to_lower() or \
	"holmes" in Autoscores.player_name.to_lower() or \
	"mycroft" in Autoscores.player_name.to_lower() or \
	"poirot" in Autoscores.player_name.to_lower() or \
	"drew" in Autoscores.player_name.to_lower() or \
	"lawliet" in Autoscores.player_name.to_lower() or \
	"conan" in Autoscores.player_name.to_lower():
		cheats = true
	
	ClutterManager.first_round = false
	ClutterManager.reset()
	#var play_area = $Background.get_rect()
	play_area = $FX/Dim.get_rect()
	var cols = 8
	var rows = 4
	var offset = Vector2(play_area.size.x/(cols)*0.5, -play_area.size.y/(rows)*0.5)

	for x in 6:
		for y in rows:
			var sorter = $Sorter.duplicate() as Sorter
			sorter.rect_position = Vector2(play_area.size.x/(cols+1)*(x+1.0), play_area.size.y/(rows)*(y+1.0))
			sorter.rect_position += offset
			sorter.rect_size = Vector2(play_area.size.x/(cols+1), play_area.size.y/(rows))
			sorter.color = Color(1.0, randf(), randf(), 0.0)
			sorter.rect_position -= sorter.rect_size / 2
			$Sorted.add_child(sorter)
			ClutterManager.droppables.append(sorter)
			initial_droppables.append(sorter)
	for x in 1:
		for y in 3:
			var sorter = $Sorter.duplicate() as Sorter
			sorter.rect_position = Vector2(play_area.size.x/(cols+1)*(x+0.0), play_area.size.y/(rows)*(y+1.0))
			sorter.rect_position += offset
			sorter.rect_size = Vector2(play_area.size.x/(cols+1), play_area.size.y/(rows))
			sorter.color = Color(1.0, randf(), randf(), 0.0)
			sorter.rect_position -= sorter.rect_size / 2
			$Sorted.add_child(sorter)
			ClutterManager.droppables.append(sorter)
			initial_notes.append(sorter)
			
	ClutterManager.droppables.append($Sorted/Sorter1)
	ClutterManager.droppables.append($Sorted/Sorter2)
	ClutterManager.droppables.append($Sorted/Sorter3)
	
	# create people
	var idx = 0
	for a in 3:
		for b in 3:
			for c in 3:
				idx += 1
				var photo = $Clutter/Photo.duplicate()
				photo.position = play_area.size/2
				photo.props = [a,b,c]
				photo.idx = idx
				people.append(photo)
				$Clutter.add_child(photo)
	# assign other properties
	people.shuffle()
	for i in len(people):
		people[i].props.append(i%3)
	people.shuffle()
	for i in len(people):
		people[i].props.append(i%3)
	people.shuffle()
	for i in len(people):
		people[i].props.append(i%3)
	
	for i in len(people):	
		people[i].person_name = Person.make_name(people[i].props, people[i].idx)
		
	
	# select culprit/suspect
	people.shuffle()
	culprit = people[0]
	# select liars and friends
	var liar_shared_property = randi()%6
	var liar_shared_property_value = culprit.props[liar_shared_property]
	for i in people:
		if i.props[liar_shared_property]==liar_shared_property_value:
			liars.append(i)
		else:
			suspects.append(i)
	for i in 3:
		friends.append(suspects.pop_front())
	for i in friends:
		i.get_node("BFF").show()
	for i in suspects:
		i.answers = [[],[],[],[]]
		i.answers_neg = [0,0,0,0]
		for j in 4:
			var other = randi()%2
			if other == culprit.props[j]:
				other += 1
			i.answers[j] = [culprit.props[j],other]
			i.answers_neg[j] = other
	for i in liars:
		if cheats:
			i.get_node("LiarLabel").show()
		i.answers = [[],[],[],[]]
		i.answers_neg = [0,0,0,0]
		for j in 4:
			var answers = []
			for k in 3:
				if k != culprit.props[j]:
					answers.append(k)
			i.answers[j] = answers
			i.answers_neg[j] = culprit.props[j]
	suspects.append_array(liars)
	for friend in friends:
		friend_to_person[friend] = []
	for i in len(suspects):
		friend_to_person[friends[i%len(friends)]].append(suspects[i])
		
	suspects.shuffle()
	people.shuffle()
	
	prints("Hey, you can use this for cheating :)")
	prints("Culprit", culprit.person_name)
	var liar_names = []
	for i in liars:
		liar_names.append(i.person_name)
	prints("Liars", Person.prop_names[liar_shared_property], Person.prop_values[liar_shared_property][liar_shared_property_value], liar_names)
		
	for i in people:
		i.call_deferred("make_person")

	
	
	ClutterManager.enabled = false
	
	$Phone.connect("hangup", self, "hangup")
	$Sorted/Sorter3.connect("dropped", self, "handle_dropped_item")
	$Sorted/Sorter2.connect("dropped", self, "accuse")
	$"%ButtonAccuse".connect("pressed", self, "accuse_check")
	$"%ButtonBack".connect("pressed", self, "close_accuse")
	$"%ButtonFailBack".connect("pressed", self, "close_accuse")
	$"%ButtonFailQuit".connect("pressed", self, "do_replay")
	$"%ButtonSuccessNext".connect("pressed", self, "do_replay")
	$"%ButtonHelp".connect("pressed", self, "do_help")
	$Accuse.hide()
	$"%ButtonHelp".hide()
	$AccuseSuccess.hide()
	$AccuseFail.hide()
	$InterrogationPaper.connect("question_asked", self, "question_asked")
	ClutterManager.clutter_container = $Clutter
	intro_setup()
	
var distributed = false
func distribute():
	if distributed:
		return
	distributed = true
	var play_area = $FX/Dim.get_rect()
	#yield(get_tree().create_timer(0.5), "timeout")
	# assign people
	if false:
		for i in len(initial_droppables):
			ClutterManager.assign(people[i], initial_droppables[i])
		for i in len(people)-len(initial_droppables):
			ClutterManager.assign(people[len(initial_droppables)+i], $Sorted/Sorter1)
	else:
		for i in len(suspects):
			ClutterManager.assign(suspects[i], initial_droppables[i])
		for i in friends:
			ClutterManager.assign(i, $Sorted/Sorter1)
	# assign notes
	for i in 3:
		var note = $Clutter/Note.duplicate()
		note.position = play_area.size/2
		note.get_node("Label").text = "Suspected liar"
		note.get_node("Post-it").modulate = Color("ef7ddd") # 738cff blue like the line
		$Clutter.add_child(note)
		ClutterManager.assign(note, initial_notes[0])
	for i in 3:
		var note = $Clutter/Note.duplicate()
		note.position = play_area.size/2
		note.get_node("Label").text = "Innocent"
		note.get_node("Post-it").modulate = Color("a1ef7d")
		$Clutter.add_child(note)
		ClutterManager.assign(note, initial_notes[1])
	for i in 3:
		var note = $Clutter/Note.duplicate()
		note.position = play_area.size/2
		note.get_node("Label").text = "Statement conflict"
		note.get_node("Post-it").modulate = Color("738cff") # 738cff blue like the line
		$Clutter.add_child(note)
		ClutterManager.assign(note, initial_notes[2])
		
	yield(get_tree().create_timer(0.5), "timeout")
	ClutterManager.enabled = true
		

	
func intro_setup():
	$Intro.show()
	var pages = [
		"Dear "+Autoscores.player_name+",\n I am writing to enlist your help.\n Our inter-academy competition trophy has been stolen. The trophy cabinet showed no signs of forced entry, suggesting an inside job. \nI believe you are uniquely positioned to uncover the truth behind the disappearance of our prized trophy.",
		"\n Not only I believe one of the students is the culprit; I know some students are keeping their secret and will lie to protect them.\n By fortunate coincidence, the theft occurred on the same day as our yearbook photography session, so I have collected all the portraits of our students taken that day. These photographs might prove invaluable to your investigation.\n",
		" To the right of your desk there is a folder, an envelope and your phone.\n The folder has pictures of your BFFs. They are not suspects and they will help you in your investigation.\n"+\
		" Once you identify the culprit, drag their picture to the envelope to make a formal accusation.\n"+\
		" Use your phone to call anyone by dragging their picture into it. You can ask suspects only one question.\n",
		"You will get to ask information about the suspect's hair color (strawberry, liquorice, banana), skin color (vanilla, caramel, chocolate), etc...",
		" You may need to ask about a specific attribute multiple times. For example, if someone tells you the hair color is strawberry or banana and someone else tells you it is banana or liquorice, then it must be banana."+\
		"\n But watch out for liars! If a liar tells you the skin color is chocolate or caramel, then for sure the culprit's skin color is neither, so it is vanilla!"+\
		"\n There are always 9 liars and they will always have something in common.",
		"\n Note that every phone call will add 5 minutes to the clock. Time is of the essence. The inter-academy competition begins in three days, and I need hardly mention the scandal that would ensue should our rival institutions learn of this theft.\n"+\
		" Focus on speed and shortcuts whenever you can. Your phone will help you track the time.\n\n                 Godspeed!"
		
	]
	var r = 0
	var page_parent = $"%IntroPaper0".get_parent()
	$"%IntroPaper0".hide()
	for i in len(pages):
		var page = $"%IntroPaper0".duplicate()
		page.show()
		page.rotation -= r
		page.set_meta("original_rotation", page.rotation)
		page_parent.add_child(page)
		page_parent.move_child(page, 1)
		intro_pages.append(page)
		page.set_text(pages[i], [])
		if i == 3:
			page.add_child(preload("res://Instructions1.tscn").instance())
		r += PI / 12
	$"%IntroPaper0".set_text("",[])
	$"%ButtonNext".connect("pressed", self, "intro_next")
	ClutterManager.enabled = false

func intro_reset():
	intro_pages_idx = 0
	ClutterManager.enabled = false
	var page_parent = $"%IntroPaper0".get_parent()
	$Intro.show()
	$"%ButtonHelp".hide()
	$"%ButtonNext".show()
	$"%ButtonNext".text = "Next"
	var tween = create_tween()
	tween.set_parallel(true)
	for page in intro_pages:
		tween.tween_property(page, "position", Vector2(230, 80), 0.3)
		tween.tween_property(page, "rotation", page.get_meta("original_rotation"), 0.3)
		page_parent.move_child(page, 1)
	tween.tween_property($"%IntroEnvelope", "position", Vector2(230,180), 0.3)

		
	

func intro_next():
	ClutterManager.play("res://assets/sfx/turn_page.wav")
	var page_parent = $"%IntroPaper0".get_parent()
	if intro_pages_idx < len(intro_pages)-1:
		page_parent.move_child(intro_pages[intro_pages_idx], 1)
		intro_pages_idx += 1
		for page in intro_pages:
			page.rotation += PI / 12
		if intro_pages_idx==len(intro_pages)-1:
			$"%ButtonNext".text = "Start"
	else:
		#ClutterManager.enabled = true
		call_deferred("distribute")
		#$Intro.hide()
		var tween = create_tween()
		tween.set_parallel(true)
		for page in intro_pages:
			tween.tween_property(page, "position", Vector2(-900, 675), 0.3)
			tween.tween_property(page, "rotation", 0.0, 0.3)
			page_parent.move_child(page, 1)
		tween.tween_property($"%IntroEnvelope", "position", Vector2(20,840), 0.3)
		$"%ButtonNext".hide()
		$"%ButtonHelp".show()
		ClutterManager.enabled = true
	
	
func handle_dropped_item(item: Node2D, accepted: bool):
	if item.is_called:
		return
		
	if item.container == $Sorted/Sorter2:
		ClutterManager.assign(item, initial_droppables[17])

	if item.has_node("Person"):
		current_interrogation = item
		ClutterManager.enabled = false
		$PhoneBack.hide()
		$"%Timer".hide()
		$PhoneFront.show()
		prints("dropped", item, item.get_node("Person").person_name)
		var dialing = ["res://assets/sfx/315921__bevibeldesign__dialing-1.wav",
		"res://assets/sfx/315920__bevibeldesign__dialing-2.wav"]
		var hello1 = ["res://assets/sfx/greeting_1_karen.wav", "res://assets/sfx/greeting_2_karen.wav", "res://assets/sfx/greeting_3_karen.wav", "res://assets/sfx/greeting_4_karen.wav", "res://assets/sfx/greeting_9_karen.wav", "res://assets/sfx/greeting_10_karen.wav"]
		var hello2 = ["res://assets/sfx/greeting_1_meghan.wav", "res://assets/sfx/greeting_2_meghan.wav", "res://assets/sfx/greeting_3_meghan.wav", "res://assets/sfx/greeting_4_meghan.wav", "res://assets/sfx/greeting_9_meghan.wav"]
		#ClutterManager.play(dialing[randi()%2])
		ClutterManager.sound_queue([
			dialing[randi()%2], 
			hello1[randi()%len(hello1)], 
			hello2[randi()%len(hello2)]
			])
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel(true)
		tween.tween_property($FX/CanvasModulate, "color", Color.white, anim_time)
		tween.tween_property($FX/Light2D, "energy", 0.0, anim_time)
		tween.tween_property($FX/Dim, "modulate", Color.white, anim_time)
		tween.tween_property($PhoneFront, "position", Vector2(1225, 532), anim_time)
		tween.tween_property($PhoneFront, "scale", Vector2(1, 1), anim_time)
		tween.tween_property($InterrogationPaper, "position", Vector2(0, 0), anim_time)
		tween.tween_property($InterrogationPaper, "rotation", 0, anim_time)
		tween.tween_callback(self, "show_interrogation").set_delay(anim_time)
		$Phone.set_person(item.get_node("Person"))
		if item in friends:
			var options = [
				]
			if len(penalties)==0:
				options.append("Do you have any tip for me?")
			else:
				options.append("Did anyone lie to me?")
				for i in friend_to_person[item]:
					options.append("Is "+i.person_name+" a liar?")

			$InterrogationPaper.set_text(
				"Ask "+item.get_node("Person").person_name, options
			)
			
				
		else:
			# "skin color", "hair color", "shirt color", "accessories"
			$InterrogationPaper.set_text(
				"Ask " + item.get_node("Person").person_name + " about:",
				[
					"Skin color.",
					"Hair color.",
					"Shirt color.",
					"Accessories."
					#"Did you see the suspect's skin color?",
					#"Do you recall the suspect's hair color?",
					#"Can you rememvber the suspect's shirt color?",
					#"Was the suspect wearing any accessories?",
				]
			)
			
		
		
func accuse(item: Node2D, accepted: bool):
	if not accepted:
		return
	#if $Sorted/Sorter2.stored and not item in $Sorted/Sorter2.stored:
		#return
	if item.has_node("Person"):
		$Accuse.show()
		$Accuse/Label.text = "Are you ready to accuse " + item.get_node("Person").person_name

func accuse_check():
	ClutterManager.enabled = false
	$Accuse.hide()
	if $Sorted/Sorter2.stored and $Sorted/Sorter2.stored[0] == culprit:
		accuse_success()
	else:
		accuse_fail()

func close_accuse():
	ClutterManager.enabled = true
	$Accuse.hide()
	$AccuseFail.hide()
	$AccuseSuccess.hide()
	
func accuse_success():
	ClutterManager.play("res://assets/sfx/588234__mehraniiii__win.wav")
	var score = compute_score()
	var score_str = format_timer(score, " ")
	
	
	$"%LabelSuccess".text = "Congratulations "+Autoscores.player_name+", you found the culprit in " + score_str
	Autoscores.do_post(score * -1, score_str)
	$confetti/confetti.emitting = true
	$confetti/confetti2.emitting = true
	$AccuseSuccess.show()
	
func accuse_fail():
	ClutterManager.play("res://assets/sfx/412427__florianreichelt__fail-sound-effect-accoustic-guitar.wav")
	$bad_confetti/CPUParticles2D.emitting = true
	$AccuseFail.show()
	bad_guesses.append($Sorted/Sorter2.stored[0])
	if $Sorted/Sorter2.stored:
		var note = $Clutter/Note.duplicate()
		note.position = play_area.size/2
		note.get_node("Label").text = $Sorted/Sorter2.stored[0].person_name + " is innocent"
		note.get_node("Post-it").modulate = Color("a1ef7d")
		$Clutter.add_child(note)
		ClutterManager.assign(note, initial_notes[2])
		
func show_interrogation():
	$PhoneFront.hide()
	$Phone.show()


func hangup():
	come_back()

		
func come_back():
	#ClutterManager.play("res://assets/sfx/hangup.wav")	
	var hello1 = ["res://assets/sfx/farewell_1_karen.wav", "res://assets/sfx/farewell_2_karen.wav", "res://assets/sfx/farewell_3_karen.wav", "res://assets/sfx/farewell_5_karen.wav", "res://assets/sfx/farewell_6_karen.wav"]
	var hello2 = ["res://assets/sfx/farewell_1_meghan.wav", "res://assets/sfx/farewell_2_meghan.wav", "res://assets/sfx/farewell_3_meghan.wav", "res://assets/sfx/farewell_5_meghan.wav", "res://assets/sfx/farewell_6_meghan.wav"]
	ClutterManager.sound_queue([
		hello1[randi()%len(hello1)], 
		#hello2[randi()%len(hello2)],
		"res://assets/sfx/hangup.wav"
		])

	
	
	current_interrogation = null
	$Phone.hide()
	$PhoneFront.show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($FX/CanvasModulate, "color", Color("b3b3b3"), anim_time)
	tween.tween_property($FX/Light2D, "energy", 0.5, anim_time)
	tween.tween_property($FX/Dim, "modulate", Color.transparent, anim_time)
	tween.tween_property($PhoneFront, "position", Vector2(1423, 893), anim_time)
	tween.tween_property($PhoneFront, "scale", Vector2(0.5, 0.5), anim_time)
	tween.tween_property($InterrogationPaper, "position", Vector2(-1000, 200), anim_time)
	tween.tween_property($InterrogationPaper, "rotation", PI/4, anim_time)
	tween.tween_callback(self, "finish_interrogation").set_delay(anim_time)


func finish_interrogation():
	$"%Timer".show()
	ClutterManager.enabled = true
	$PhoneBack.show()
	$PhoneFront.hide()
	pass

func distibute_liar_notes(count):
	
	for i in (count-liar_notes_distributed):
		var note = $Clutter/Note.duplicate()
		note.position = play_area.size/2
		note.get_node("Label").text = "Liar"
		note.get_node("Post-it").modulate = Color("ee855c") # ff4f4f too dark
		$Clutter.add_child(note)
		ClutterManager.assign(note, initial_notes[0])
	liar_notes_distributed = count


func question_asked(item_idx):
	if current_interrogation in liars:
		print("this is a lie")
	elif current_interrogation in friends:
		print("this comes from a friend")
	elif current_interrogation in suspects:
		print("this is a regular suspect")
	else:
		print("we don't know who this is")
		
	if not current_interrogation in friends:
		prints("setting called")
		current_interrogation.is_called = true
		current_interrogation.get_node("Called").show()
		
	var hello1 = ["res://assets/sfx/miscellaneous_2_karen.wav", "res://assets/sfx/miscellaneous_3_karen.wav", "res://assets/sfx/miscellaneous_10_karen.wav"]
	var hello2 = ["res://assets/sfx/confirmation_2_karen.wav", "res://assets/sfx/confirmation_8_karen.wav", "res://assets/sfx/confirmation_9_karen.wav", "res://assets/sfx/confirmation_10_karen.wav"]
	var hello3 = ["res://assets/sfx/miscellaneous_3_karen.wav", "res://assets/sfx/miscellaneous_3_meghan.wav"]
	ClutterManager.sound_queue([
		#hello1[randi()%len(hello1)],
		#hello2[randi()%len(hello2)],
		hello3[randi()%len(hello3)],
		]
		)

	
	var questions = [
				"Did you see if the person's skin was X?".replace("X", Person.prop_values[0][randi()%3]),
				"Do you recall if the person had X hair?".replace("X", Person.prop_values[1][randi()%3]),
				"Can you remember if the shirt of the person was X?".replace("X", Person.prop_values[2][randi()%3]),
				"Was the person you saw wearing any X?".replace("X", Person.prop_values[3][randi()%3]),
			]
	var text_question = ""
	var text_answer = ""
	var note_answer = ""
	if current_interrogation in friends:
		if item_idx == 0:
			if len(penalties)==0:
				text_question = "Do you have any tip for me?"
				text_answer = "Nothing right now but make sure to ask me later :)"
				note_answer = ""
			else:
				text_question = "Did anyone lie to me?"
				var count_lies = 0
				for penalty in penalties:
					if penalty[0] in liars:
						count_lies += 1
				if count_lies == 0:
					text_answer = "No one has lied to you yet."
					note_answer = "0 liars"
				elif count_lies == 1:
					text_answer = "One person has lied to you already."
					note_answer = "1 liar"
				else:
					text_answer = "%d people have lied to you already." % count_lies
					note_answer = "%d liars" % count_lies
				distibute_liar_notes(count_lies)
		else:
			var asked_about = friend_to_person[current_interrogation][item_idx-1]
			text_question = "Do you know if "+asked_about.person_name+" is a liar?"
			if asked_about in liars:
				text_answer = "Yes, "+asked_about.person_name+" is a liar."
				note_answer = asked_about.person_name+" is a liar"
			else:
				text_answer = "No, "+asked_about.person_name+" is not a liar."
				note_answer = asked_about.person_name+" not a liar"			
	else:
		var answer = "%s or %s" % [
			Person.prop_values[item_idx][current_interrogation.answers[item_idx][0]], 
			Person.prop_values[item_idx][current_interrogation.answers[item_idx][1]]
			]
		answer = Person.prop_values[item_idx][current_interrogation.answers_neg[item_idx]]
		text_question = questions[item_idx]
		text_answer = "mmm... it was not " + answer
		note_answer = Person.prop_names[item_idx] + "\nnot " + answer
		

	if current_interrogation:
		prints("question_asked", current_interrogation, item_idx)
		$Phone.advance_dialog(
			text_question,
			text_answer #"Maybe. I think It was either strawberry or chocolate"
		)
		penalties.append([current_interrogation, item_idx])
		var container = current_interrogation.container
		if not container:
			print("error, this interrogation doens't have a container")
		else:
			if note_answer != "":
				var note = $Clutter/Note.duplicate()
				note.position = play_area.size/2
				note.get_node("Label").text = note_answer
				#note.get_node("Post-it").modulate = Color("ee855c") # ff4f4f too dark
				$Clutter.add_child(note)
				ClutterManager.assign(note, container)

		

func _process(delta):
	update_timer(delta)
	
func update_timer(delta):
	if not ClutterManager.enabled:
		return
	elapsed += delta
	timer.text = format_timer(compute_score(), "\n")

func compute_score():
	var score = int(ceil(elapsed))
	score += 300 * len(penalties)
	score += 1800 * len(bad_guesses)
	return score
	

func format_timer(score, separator):
	if score >= 3600:
		var hours = score / 3600
		var minutes = score % 3600
		var seconds = minutes % 60
		minutes /= 60
		return str(hours) + "h" + separator + ("%02d:%02d" % [minutes, seconds])
	else:
		var minutes = score % 3600
		var seconds = minutes % 60
		minutes /= 60
		return ("%02d:%02d" % [minutes, seconds])

func do_help():
	intro_reset()
	
func do_replay():
	get_tree().change_scene("res://desktop1.tscn")
