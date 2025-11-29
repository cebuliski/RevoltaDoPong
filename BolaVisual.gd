extends Node2D

# Raio do círculo (metade do tamanho do ColorRect original)
export var raio: float = 15.0

export var cor: Color = Color.white

func _draw() -> void:
	draw_circle(Vector2.ZERO, raio, cor)

