extends Node

var acceleration := 28.0
var max_speed := 18.0
var grip := 10.0 # Maximum grip (no drift)

func add_speed(addSpeed):
	max_speed += addSpeed

func add_accel(addAccel):
	acceleration += addAccel

func add_handle(addGrip):
	grip += addGrip
