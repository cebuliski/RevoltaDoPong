extends Node2D
class_name Jogo

# ===== VARIÁVEIS DE CONTROLE =====

# Contador de alvos ainda ativos no jogo
# Inicia com 3 pois temos Alvo, Alvo2 e Alvo3 na cena
var alvos_vivos: int = 3

# Contador de alvos que já foram destruídos
# Usado para rastreamento e possível exibição de estatísticas
var alvos_destruidos: int = 0


# ===== REFERÊNCIAS DA CENA =====

# Referências diretas aos três alvos presentes na cena
# Cada alvo começa com 3 pontos de vida (configurado em Jogo.tscn)
onready var alvo1: Alvo = $Alvo
onready var alvo2: Alvo = $Alvo2
onready var alvo3: Alvo = $Alvo3

# Referência à camada de interface de Game Over
# CanvasLayer com pause_mode = 2 para funcionar mesmo com o jogo pausado
onready var game_over_ui: CanvasLayer = $GameOverUI


# ===== FUNÇÕES DE INICIALIZAÇÃO =====

func _ready():
	# Garante que a interface de Game Over está invisível no início do jogo
	# Ela só deve aparecer quando todos os alvos forem destruídos
	game_over_ui.visible = false
	
	# Conecta os sinais de destruição de cada alvo para o gerenciador principal
	# Isso permite que o jogo saiba quando um alvo foi eliminado
	conectar_sinais_alvos()


func conectar_sinais_alvos():
	# Conecta o primeiro alvo
	# A verificação 'if alvo1' previne erro caso o nó não exista
	# A verificação 'is_connected' evita conectar o mesmo sinal múltiplas vezes
	if alvo1 and not alvo1.is_connected("destruido", self, "_on_Alvo_destruido"):
		alvo1.connect("destruido", self, "_on_Alvo_destruido")
	
	# Conecta o segundo alvo
	if alvo2 and not alvo2.is_connected("destruido", self, "_on_Alvo_destruido"):
		alvo2.connect("destruido", self, "_on_Alvo_destruido")
	
	# Conecta o terceiro alvo
	if alvo3 and not alvo3.is_connected("destruido", self, "_on_Alvo_destruido"):
		alvo3.connect("destruido", self, "_on_Alvo_destruido")


# ===== CALLBACKS DE SINAIS =====

func _on_Alvo_destruido(_alvo: Alvo):
	# Incrementa o contador de alvos destruídos
	alvos_destruidos += 1
	
	# Decrementa o contador de alvos ainda vivos
	alvos_vivos -= 1
	
	# Verifica se todos os alvos foram eliminados
	# Quando alvos_vivos chega a zero ou menos, o jogador perdeu
	if alvos_vivos <= 0:
		game_over()


func _on_BotaoReiniciar_pressed():
	# Remove a pausa do jogo para permitir que a cena seja recarregada corretamente
	# O jogo foi pausado na função game_over()
	get_tree().paused = false
	
	# Recarrega a cena atual (Jogo.tscn) do início
	# Isso reseta todos os alvos, a bola, as raquetes e os contadores
	get_tree().reload_current_scene()


# ===== FUNÇÕES DE GERENCIAMENTO DO JOGO =====

func game_over():
	# Pausa todas as atividades do jogo
	# Nós com pause_mode = 2 (como GameOverUI) continuam funcionando
	# Isso congela a bola, raquetes e tiros enquanto mostra a tela de derrota
	get_tree().paused = true
	
	# Torna visível a camada de interface de Game Over
	# Exibe o overlay escuro, o painel, a mensagem e o botão de reiniciar
	# O botão já está conectado ao método _on_BotaoReiniciar_pressed() pelo editor (Node -> pressed)
	game_over_ui.visible = true
