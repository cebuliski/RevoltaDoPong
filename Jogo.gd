extends Node2D
class_name Jogo

var alvos_vivos: int = 3

# Contador de alvos que já foram destruídos
# Usado para rastreamento e possível exibição de estatísticas
var alvos_destruidos: int = 0

onready var alvo1: Alvo = $Alvo
onready var alvo2: Alvo = $Alvo2
onready var alvo3: Alvo = $Alvo3

# Referência à bola para conectar o sinal de colisão com parede de derrota
onready var bola: Bola = $Bola

# Referência à camada de interface de Game Over
# CanvasLayer com pause_mode = 2 para funcionar mesmo com o jogo pausado
onready var game_over_ui: CanvasLayer = $GameOverUI


# ===== FUNÇÕES DE INICIALIZAÇÃO =====

func _ready():
	# GARANTIA: Força o jogo a NÃO estar pausado ao iniciar
	# Isso resolve o bug da bola parada após reiniciar
	get_tree().paused = false
	
	# Garante que a interface de Game Over está invisível no início do jogo
	# Ela só deve aparecer quando todos os alvos forem destruídos
	game_over_ui.visible = false
	
	# Conecta os sinais de destruição de cada alvo para o gerenciador principal
	# Isso permite que o jogo saiba quando um alvo foi eliminado
	conectar_sinais_alvos()
	
	# Conecta o sinal da bola que detecta colisão com a parede de derrota
	# Quando a bola passar da RaqueteJogador e bater na ParedeLateral1, o jogo termina
	conectar_sinal_bola()


func conectar_sinais_alvos():
	# Conecta o primeiro alvo

	# A verificação 'is_connected' evita conectar o mesmo sinal múltiplas vezes
	if alvo1 and not alvo1.is_connected("destruido", self, "_on_Alvo_destruido"):
		alvo1.connect("destruido", self, "_on_Alvo_destruido")
	
	# Conecta o segundo alvo
	if alvo2 and not alvo2.is_connected("destruido", self, "_on_Alvo_destruido"):
		alvo2.connect("destruido", self, "_on_Alvo_destruido")
	
	# Conecta o terceiro alvo
	if alvo3 and not alvo3.is_connected("destruido", self, "_on_Alvo_destruido"):
		alvo3.connect("destruido", self, "_on_Alvo_destruido")


func conectar_sinal_bola():
	# Conecta o sinal da bola que indica colisão com a parede de Game Over
	# Esse sinal é emitido quando a bola ultrapassa a RaqueteJogador e bate na ParedeLateral1
	if bola and not bola.is_connected("bateu_parede_game_over", self, "_on_Bola_bateu_parede_game_over"):
		bola.connect("bateu_parede_game_over", self, "_on_Bola_bateu_parede_game_over")

func _on_Alvo_destruido(_alvo: Alvo):
	# Incrementa o contador de alvos destruídos
	alvos_destruidos += 1
	
	# Decrementa o contador de alvos ainda vivos
	alvos_vivos -= 1
	
	# Verifica se todos os alvos foram eliminados
	# Quando alvos_vivos chega a zero ou menos, o jogador perdeu
	if alvos_vivos <= 0:
		game_over()


func _on_Bola_bateu_parede_game_over():
	# Callback chamado quando a bola bate na parede de derrota (ParedeLateral1)
	# Isso significa que o jogador não conseguiu defender com a RaqueteJogador
	game_over()


func _on_BotaoReiniciar_pressed():
	# Remove a pausa do jogo para permitir que a cena seja recarregada corretamente
	# O jogo foi pausado na função game_over()
	get_tree().paused = false
	
	# Recarrega a cena atual (Jogo.tscn) do início
	# Isso reseta todos os alvos, a bola, as raquetes e os contadores
	get_tree().reload_current_scene()

func game_over():
	# Pausa todas as atividades do jogo
	# Nós com pause_mode = 2 (como GameOverUI) continuam funcionando
	# Isso congela a bola, raquetes e tiros enquanto mostra a tela de derrota
	get_tree().paused = true
	
	# Torna visível a camada de interface de Game Over
	game_over_ui.visible = true
