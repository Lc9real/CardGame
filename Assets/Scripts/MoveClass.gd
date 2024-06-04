class_name MoveClass

var pos: Vector3
var speed: int
var rot: bool

func _init(_pos:Vector3,_speed:int,_rot:bool=false): 
	speed = _speed
	pos = _pos
	rot = _rot
