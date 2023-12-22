extends Node2D
export var gridPx = Vector2()
export var gridSpacing = Vector2()

var selecting = false
var selected = []

var MATCH = []
var img = []

func _ready():
	$Button.connect("pressed", self, "start")
	$shuffle.connect("pressed", self, "shuffle")
	print("ready!")
	generate()

func generate():
	randomize()
	var amount = 24
	for i in amount:
		img.append(Color(randf(), randf(), randf(), 1))
		var template = {
			"clicked": false, #whether or not the card has been clicked.
			"myId": i, #the unique card id for processing
			"matchId": i, #the matching id
		}
		MATCH.append(template)
		template = template.duplicate(true) #deref
		template.myId += 1
		MATCH.append(template)
	MATCH.shuffle()
	print("done!")

func render():
	for child in $Tile.get_children():
		$Tile.remove_child(child)
		child.queue_free()

	for tileIndex in MATCH.size():
		var tileInstance = preload("TileInstance.tscn").instance()
		var tileData = MATCH[tileIndex]
		tileInstance.get_node("icon").frame = wrapi(tileData.matchId, 0, 0)
		tileInstance.get_node("icon").self_modulate = img[tileData.matchId]
		tileInstance.get_node("click").connect("input_event", self, "_tileClick", [tileData, tileInstance])
		tileInstance.position = Vector2(tileIndex % int(gridPx.x), floor(tileIndex / gridPx.x)) * gridSpacing
		$Tile.add_child(tileInstance)

func _tileClick(vp, event:InputEvent, shape, tileData, node):
	if !(event.is_action("click") and event.pressed): return
	if !selecting:
		print(str(tileData.matchId))
		selecting = true
		tileData.clicked = !tileData.clicked
		selected = [tileData, node]
		node.get_node("icon").modulate = Color.black
	else:
		node.get_node("icon").modulate = Color.white
		selected[1].get_node("icon").modulate = Color.white
		if tileData.matchId != selected[0].matchId:
			#$WRONG.play()
			print("WRONG")
		elif tileData == selected[0]: print("thats the same one lol")
		else:
			#$Right.play()
			print("thats right!")
			MATCH.remove(MATCH.find(tileData))
			MATCH.remove(MATCH.find(selected[0]))
			node.queue_free()
			selected[1].queue_free()
			for resetID in MATCH.size(): MATCH[resetID].myId = resetID
			
		selecting = false
		selected = []

func start():
	$Button.queue_free()
	shuffle()

func shuffle():
	MATCH.shuffle()
	for resetID in MATCH.size(): MATCH[resetID].myId = resetID
	render()
	print(str(MATCH))
