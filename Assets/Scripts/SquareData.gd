class_name  SquareData

var id: int

var x: int
var y: int

var x_pos: float
var y_pos: float

var occupied: bool
var cardID: int
var ownerID: int
var card: Node3D
var type: MyEnums.Types

func _init(_x: int, _y: int, _id: int, scale: float, fieldSize: int):
	id = _id
	x = _x
	y = _y
	
	occupied = false
	cardID = 0
	
	
	
	var step: float = scale/fieldSize
	var offset = (scale-2)/-2
	
	x_pos = offset+(step*x)
	y_pos = offset+(step*y)
