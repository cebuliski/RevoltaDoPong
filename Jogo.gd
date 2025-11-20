extends Node2D

# Variáveis de pontuação
var pontos_jogador: int = 0
var pontos_maquina: int = 0

# Referências aos textos na tela (Verifique se os caminhos estão certos na sua cena)
onready var label_jogador = $CanvasLayer/LabelJogador
onready var label_maquina = $CanvasLayer/LabelMaquina

# Referências aos alvos na cena
onready var alvo1 = $Alvo
onready var alvo2 = $Alvo2
onready var alvo3 = $Alvo3

func _ready():
	atualizar_placar_visual()
	conectar_sinais_dos_alvos()

func conectar_sinais_dos_alvos():

	if is_instance_valid(alvo1):
		alvo1.connect("alvo_atingido", self, "_on_Alvo_atingido")
	
	if is_instance_valid(alvo2):
		alvo2.connect("alvo_atingido", self, "_on_Alvo_atingido")
		
	if is_instance_valid(alvo3):
		alvo3.connect("alvo_atingido", self, "_on_Alvo_atingido")

# Esta função é chamada sempre que qualquer alvo emite o sinal
func _on_Alvo_atingido():
	# A lógica solicitada: Se um alvo for atingido, ponto para a Máquina (Adversário)
	pontos_maquina += 1
	atualizar_placar_visual()

func atualizar_placar_visual():
	# Atualiza o texto dos Labels
	label_jogador.text = "JOGADOR: " + str(pontos_jogador)
	label_maquina.text = "MÁQUINA: " + str(pontos_maquina)
