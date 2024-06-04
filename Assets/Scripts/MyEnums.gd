class_name MyEnums

var duration: int
var strength: float



enum Types {
	NORMAL,
	POISON,
	DARKNESS,
	LIGHT,
	UNDEAD,
}

enum Effects {
	WEAKNESS,
	FREEZE,
	POISON,
	REGENERATION, 
	SCHIELD
}

func _init(_duration, _strength):
	duration = _duration
	strength = _strength
