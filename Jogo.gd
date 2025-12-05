extends Node2D
class_name Jogo

# ===== ENUM DE BÔNUS =====

# Tipos de bônus que o jogador pode ganhar ao interceptar tiros
enum TipoBonus {
	RAQUETE_GIGANTE,  # Dobra o tamanho da raquete por 5 segundos
	RAQUETE_PEQUENA,  # Diminui o tamanho da raquete por 5 segundos
	SLOW_MOTION       # Reduz velocidade da bola pela metade por 5 segundos
}


# ===== VARIÁVEIS DE CONTROLE =====

var alvos_vivos: int = 3

# Contador de alvos que já foram destruídos
# Usado para rastreamento e possível exibição de estatísticas
var alvos_destruidos: int = 0

# Variável para armazenar a pontuação do jogador
var pontuacao: int = 0

# ===== VARIÁVEIS DE BÔNUS =====

# Controle de bônus ativos
var bonus_raquete_gigante_ativo: bool = false
var bonus_slow_motion_ativo: bool = false
var bonus_raquete_maquina_pequena_ativa: bool = false

# Valores originais para restaurar após bônus
var raquete_jogador_scale_original: Vector2 = Vector2.ONE
var raquete_maquina_scale_original: Vector2 = Vector2.ONE
var bola_velocidade_max_original: float = 300.0

# Duração dos bônus em segundos
const DURACAO_BONUS: float = 5.0

# ===== REFERÊNCIAS DA CENA =====
onready var alvo1: Alvo = $Alvo
onready var alvo2: Alvo = $Alvo2
onready var alvo3: Alvo = $Alvo3

# Referência à bola para conectar o sinal de colisão com parede de derrota
onready var bola: Bola = $Bola

# Referência à raquete do jogador para aplicar bônus
onready var raquete_jogador: KinematicBody2D = $RaqueteJogador

# Referência à raquete do maquina para aplicar bônus
onready var raquete_maquina: KinematicBody2D = $RaqueteMaquina

# Referência à camada de interface de Game Over
# CanvasLayer com pause_mode = 2 para funcionar mesmo com o jogo pausado
onready var game_over_ui: CanvasLayer = $GameOverUI

# Referência ao Label do Placar, dentro do PanelContainer
onready var placar_ui: Label = $Interface/BoxPontuacao/Placar

# Referência ao nó Tween de animação (NOVO para o Game Juice)
onready var tween_placar: Tween = $Tween

# Referência ao label que mostra bônus ativos
onready var label_bonus: Label = $BonusUI/LabelBonus


# ===== FUNÇÕES DE INICIALIZAÇÃO =====

func _ready():
	# Isso resolve o bug da bola parada após reiniciar
	get_tree().paused = false
	
	# Garante que a interface de Game Over está invisível no início do jogo
	# Ela só deve aparecer quando todos os alvos forem destruídos
	game_over_ui.visible = false
	

	# Reseta o placar visualmente e aplica as configurações iniciais
	atualizar_placar_visual()
	
	if placar_ui:
		placar_ui.rect_pivot_offset = placar_ui.rect_size / 2

	# Salva valores originais para restaurar após bônus
	if raquete_jogador:
		raquete_jogador_scale_original = raquete_jogador.scale
	if bola:
		bola_velocidade_max_original = bola.velocidade_maxima
	if raquete_maquina:
		raquete_maquina_scale_original = raquete_maquina.scale
	
	# Conecta os sinais de destruição de cada alvo para o gerenciador principal
	conectar_sinais_alvos()
	
	# Conecta o sinal da bola que detecta colisão com a parede de derrota
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

# Função para adicionar pontos e atualizar a tela
func adicionar_pontos(quantidade: int):
	pontuacao += quantidade
	atualizar_placar_visual()
	# Chama a animação sempre que ganha pontos
	animar_placar()

func atualizar_placar_visual():
	if placar_ui:
		# Define o texto como "Pontuação: X"
		placar_ui.text = "Pontuação: " + str(pontuacao)
		
		# Recalcula o pivô caso o tamanho do texto mude
		placar_ui.rect_pivot_offset = placar_ui.rect_size / 2

# Função que faz o placar "Pulsar"
func animar_placar():
	# Se o tween ou o placar não existirem, aborta
	if not tween_placar or not placar_ui:
		return
		
	# Para qualquer animação anterior que ainda esteja rodando no placar
	tween_placar.stop_all()
	
	# FASE 1: Crescer (Scale up)
	tween_placar.interpolate_property(
		placar_ui, "rect_scale", 
		Vector2.ONE, Vector2(1.5, 1.5), 0.1, 
		Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	
	# FASE 2: Voltar ao normal (Scale down)
	tween_placar.interpolate_property(
		placar_ui, "rect_scale", 
		Vector2(1.5, 1.5), Vector2.ONE, 0.2, 
		Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.1
	)
	
	# Inicia a animação
	tween_placar.start()

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


# ===== SISTEMA DE BÔNUS =====

func _on_Tiro_interceptado():
	# Callback chamado quando o jogador intercepta um tiro com a raquete
	# Sorteia um bônus aleatório e ativa
	
	# Sorteia um tipo de bônus (0 ou 1)
	# var bonus_sorteado = randi() % 3
	var bonus_sorteado = randi() % TipoBonus.size()
	
	match bonus_sorteado:
		TipoBonus.RAQUETE_GIGANTE:
			ativar_bonus_raquete_gigante()
		TipoBonus.RAQUETE_PEQUENA:
			ativar_bonus_raquete_pequena()
		TipoBonus.SLOW_MOTION:
			ativar_bonus_slow_motion()


func ativar_bonus_raquete_gigante():
	# Impede ativar bônus duplicado
	if bonus_raquete_gigante_ativo:
		return
	
	bonus_raquete_gigante_ativo = true
	
	# Dobra o tamanho da raquete do jogador
	raquete_jogador.scale = raquete_jogador_scale_original * 2.0
	
	# Feedback visual
	mostrar_label_bonus("🔵 RAQUETE GIGANTE!")
	
	# Cria timer para desativar após duração
	yield(get_tree().create_timer(DURACAO_BONUS), "timeout")
	desativar_bonus_raquete_gigante()

func desativar_bonus_raquete_gigante():
	# Restaura o tamanho original da raquete
	if raquete_jogador:
		raquete_jogador.scale = raquete_jogador_scale_original
	
	bonus_raquete_gigante_ativo = false

func ativar_bonus_raquete_pequena():
	# Impede ativar bônus duplicado
	if bonus_raquete_maquina_pequena_ativa:
		return
	
	bonus_raquete_maquina_pequena_ativa = true
	
	# Dobra o tamanho da raquete do maquina
	raquete_maquina.scale = raquete_maquina_scale_original / 2.0
	
	# Feedback visual
	mostrar_label_bonus("🔵 RAQUETE PEQUENA!")
	
	# Cria timer para desativar após duração
	yield(get_tree().create_timer(DURACAO_BONUS), "timeout")
	desativar_bonus_raquete_pequena()

func desativar_bonus_raquete_pequena():
	# Restaura o tamanho original da raquete
	if raquete_maquina:
		raquete_maquina.scale = raquete_maquina_scale_original
	
	bonus_raquete_maquina_pequena_ativa = false

func ativar_bonus_slow_motion():
	# Impede ativar bônus duplicado
	if bonus_slow_motion_ativo:
		return
	
	bonus_slow_motion_ativo = true
	
	# Reduz a velocidade máxima da bola pela metade
	bola.velocidade_maxima = bola_velocidade_max_original * 0.8
	
	# Se a bola estiver mais rápida que o novo limite, reduz a velocidade atual
	if bola.velocidade.length() > bola.velocidade_maxima:
		bola.velocidade = bola.velocidade.normalized() * bola.velocidade_maxima
	
	# Feedback visual
	mostrar_label_bonus("⏰ SLOW MOTION!")
	
	# Cria timer para desativar após duração
	yield(get_tree().create_timer(DURACAO_BONUS), "timeout")
	desativar_bonus_slow_motion()


func desativar_bonus_slow_motion():
	# Restaura a velocidade máxima original da bola
	if bola:
		bola.velocidade_maxima = bola_velocidade_max_original
	
	bonus_slow_motion_ativo = false

func mostrar_label_bonus(texto: String):
	# Exibe o label de bônus temporariamente
	if label_bonus:
		label_bonus.text = texto
		label_bonus.visible = true
		
		# Esconde após 2 segundos
		yield(get_tree().create_timer(2.0), "timeout")
		label_bonus.visible = false


# ===== CALLBACKS DE SINAIS =====
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
