extends Node2D
class_name CameraPivot

export var follow_speed: float = 8.0
# export var limit_rect: Rect2
# onready var bola: Bola = get_parent().get_node("Bola")
onready var bola_corpo: KinematicBody2D = get_node_or_null("../Bola/CorpoBola")

func _ready() -> void:
	pass # se precisar, chame super()

func _physics_process(delta: float) -> void:
	print(bola_corpo)
	global_position = global_position.linear_interpolate(bola_corpo.global_position, follow_speed * delta)
