extends Node2D
export var gridWidth = 0
export var gridSpacing = Vector2()

var selecting = false
var selected = ["", 0]


var MATCH = [



]

func _ready():
	$Label.text = "ready!"
	
	silly()


func silly():
	var amount = 48
	while amount > 0:
		var uniqueId = amount
		var templateID = amount - (amount % 2)
		var templateName = "Flower" + String(templateID)
		var templateDesc = "Description"
		var templateIMG = "flowey"
		var template = [templateName, templateDesc, templateIMG, false, templateID, uniqueId]
		MATCH.append(template)
		amount -= 1
	MATCH.shuffle()
	$Label.text = "done!"

func render():
	var delet = $Tile.get_child_count()
	while delet > 0:
		$Tile.get_child(delet).queue_free()
		delet -= 1


	var tileIndex = 0
	while tileIndex < MATCH.size():
		var tileInstance = preload("res://Assets/TileInstance.tscn").instance()
		var tileData = MATCH[tileIndex]
		var tileName = tileData[0]
		var tileDesc = tileData[1]
		var tileIMG = tileData[2]
		tileInstance.get_node("icon").animation = tileIMG
		tileInstance.get_node("Button").connect("pressed", self, "_tileClick", [tileIndex])
		
		var tileMOD = Vector2()
		tileMOD.x = tileData[5] % gridWidth
		tileMOD.y = floor(tileData[5] / gridWidth)
		tileMOD.x *= gridSpacing.x
		tileMOD.y *= gridSpacing.y
		
		tileInstance.position = tileMOD
		
		
		$Tile.add_child(tileInstance)
		
		tileIndex += 1
		

func _tileClick(idx):
	var tileData = MATCH[idx]
	if selecting == false:
		selecting = true
		tileData[3] = !tileData[3]
		selected[1] = idx
		$Tile.get_child(idx).get_node("icon").modulate.r = 0
		$Label.text = tileData[0]
	elif selecting == true:
		if tileData[4] != MATCH[selected[1]][4]:
			$WRONG.play()
			$Label.text = "WRONG"
			$Tile.get_child(selected[1]).get_node("icon").modulate.r = 1
		elif idx == selected[1]:
			$Label.text = "thats the same one lol"
			$Tile.get_child(selected[1]).get_node("icon").modulate.r = 1
		if tileData[4] == MATCH[selected[1]][4] and idx != selected[1]:
			$Right.play()
			$Label.text = "thats right!"
			var which = 0
			var one = 0
			if idx > selected[1]:
				which = idx
				one = selected[1]
			elif selected[1] > idx:
				which = selected[1]
				one = idx
			$Tile.get_child(which).queue_free()
			MATCH.remove(which)
			$Tile.get_child(one).queue_free()
			MATCH.remove(one)
		selecting = false
		selected = ["", 0]



func _on_Button_pressed():
	$Button.queue_free()
	_on_shuffle_pressed()
	


func _on_shuffle_pressed():
	MATCH.shuffle()
	var resetID = 0
	while resetID < MATCH.size():
		MATCH[resetID][5] = resetID
		resetID += 1
	render()
	$Label.text = String(MATCH)
