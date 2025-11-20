extends Area2D
class_name Alvo

export var vida: int = 1

# Sinais para avisar o jogo
signal destruido
signal alvo_atingido

func _ready():
	if not self.is_connected("body_entered", self, "_on_Alvo_body_entered"):
		self.connect("body_entered", self, "_on_Alvo_body_entered")

# Função chamada quando um corpo físico colide com esta área
func _on_Alvo_body_entered(corpo):
	if corpo is Tiro:
		# Avisa que foi atingido antes de processar o dano
		emit_signal("alvo_atingido")
		
		levar_dano(1)
		corpo.queue_free()

func levar_dano(quantidade: int):
	vida -= quantidade
	
	if vida <= 0:
		destruir()

func destruir():
	emit_signal("destruido", self)
	queue_free()
