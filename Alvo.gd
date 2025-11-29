extends Area2D
class_name Alvo

export var vida: int = 3

signal destruido

func _ready():
	if not self.is_connected("body_entered", self, "_on_Alvo_body_entered"):
		self.connect("body_entered", self, "_on_Alvo_body_entered")

# Função chamada quando um corpo físico colide com esta área
func _on_Alvo_body_entered(corpo):
	if corpo is Tiro:
		levar_dano(1)
		corpo.queue_free()

func levar_dano(quantidade: int):
	vida -= quantidade
	
	# Se a vida zerar, aí sim destrói e avisa o Jogo
	if vida <= 0:
		destruir()

func destruir():
	emit_signal("destruido", self)
	queue_free()
