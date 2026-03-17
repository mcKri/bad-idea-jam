extends Node

var acceleration: float = 28.0
var max_speed: float = 18.0
var grip: float = 10.0 # Maximum grip (no drift)

func add_speed(addSpeed):
	max_speed += addSpeed

func add_accel(addAccel):
	acceleration += addAccel

func add_handle(addGrip):
	grip += addGrip
