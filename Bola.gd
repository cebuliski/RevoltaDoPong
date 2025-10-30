extends Node2D
class_name Bola

# Cena do tiro a ser instanciada pela bola
# Esta cena contém um projétil pronto (visual + colisão)
export(PackedScene) var Tiro

# Controle de disparo
# pode_atirar: trava simples para garantir 1 tiro por evento
# bola_no_centro: edge detection para só disparar quando ENTRAR na faixa central
# bateu_raquete_maquina: marca que a última colisão foi com a raquete da máquina
var pode_atirar: bool = false
var bola_no_centro: bool = false
var bateu_raquete_maquina: bool = false

# Posição X da linha central e tolerância de faixa para detecção
const CENTRO_X: float = 512.0
const TOLERANCIA_CENTRO: float = 4.0 # Margem de erro em pixels em torno da linha central para considerar que a bola "cruzou" a linha central

# Velocidade e física da bola
# velocidade_inicial: módulo da velocidade no saque
# velocidade_maxima: teto de velocidade para manter o jogo controlável
# aceleracao_por_colisao: incremento aplicado após cada colisão relevante
export var velocidade_inicial = 300
export var velocidade_maxima = 800
export var aceleracao_por_colisao = 50
var velocidade = Vector2.ZERO

# Referência para o corpo da bola (KinematicBody2D)
# O script fica no Node2D raiz para orquestração, a física ocorre no filho
onready var corpo_bola = $CorpoBola

# Função chamada quando o nó entra na árvore da cena
func _ready():
	# Inicializa o gerador de números aleatórios para variação do saque
	randomize()
	
	# Prepara a bola com direção e velocidade iniciais
	iniciar_bola()


# Função que inicia a bola com direção aleatória
func iniciar_bola():
	# Gera um ângulo aleatório entre -45 e 45 graus (saque controlado)
	var angulo = rand_range(-PI/4, PI/4)
	
	# 50% de chance de inverter a direção horizontal (sorteia lado do saque)
	if randf() < 0.5:
		angulo += PI  # Inverte a direção horizontal
	
	# Define a velocidade inicial baseada no ângulo
	velocidade = Vector2(cos(angulo), sin(angulo)) * velocidade_inicial

# Função de física chamada a cada frame
func _physics_process(delta):
	# Calcula o deslocamento da bola para este frame
	var movimento = velocidade * delta
	
	# move_and_collide retorna a colisão ocorrida neste frame (se houver)
	var colisao: KinematicCollision2D = corpo_bola.move_and_collide(movimento)
	
	# Se houve colisão, processa o rebote
	if colisao:
		processar_colisao(colisao)
	
	# Dispara ao CRUZAR a faixa central (edge detection)
	# Condição AND: só dispara se também tiver batido na RaqueteMaquina
	var no_centro := abs(corpo_bola.global_position.x - CENTRO_X) <= TOLERANCIA_CENTRO
	if no_centro and not bola_no_centro and bateu_raquete_maquina:
		# Direção do tiro acompanha o sentido X atual da bola
		var direcao_x
		if velocidade.x >= 0.0:
			direcao_x = 1.0
		else:
			direcao_x = -1.0
		var dir = Vector2(direcao_x, 0.0)
		habilitar_e_disparar(dir)
		# Consome o evento de colisão com a raquete da máquina
		bateu_raquete_maquina = false
	bola_no_centro = no_centro


# Colisão e rebote. Atualiza estado para disparo condicional
func processar_colisao(colisao: KinematicCollision2D):
	# Obtém a normal da colisão (direção perpendicular à superfície)
	var normal = colisao.normal
	
	# Reflete a velocidade da bola na superfície de colisão
	velocidade = velocidade.bounce(normal)
	
	# Aumenta ligeiramente a velocidade para tornar o jogo mais dinâmico
	velocidade = velocidade.normalized() * min(velocidade.length() + aceleracao_por_colisao, velocidade_maxima)
	
	# Marca que a última colisão foi com a RaqueteMaquina (parte 1 da condição AND)
	var quem_bateu = colisao.get_collider()
	if quem_bateu is RaqueteMaquina:
		bateu_raquete_maquina = true
	
	# Verifica se a bola colidiu com as paredes superior ou inferior
	if abs(normal.y) > 0.9:  # Colisão com parede superior/inferior
		# Ajusta a posição da bola para evitar que fique "grudada" na parede
		corpo_bola.position += normal * 2


# Dispara um único tiro se ainda não houve disparo autorizado neste evento
# Esta função implementa a trava anti-spam de projéteis
func habilitar_e_disparar(dir: Vector2):
	# Garante 1 tiro por evento
	if pode_atirar:
		return
	pode_atirar = true
	disparar_tiro(dir)
	pode_atirar = false


# Instancia e dispara um tiro a partir da bola
# O tiro nasce no centro do corpo físico da bola e é adicionado à cena atual
func disparar_tiro(dir: Vector2):
	if not Tiro:
		return
	var tiro = Tiro.instance()
	# Sai do centro do corpo da bola
	tiro.global_position = corpo_bola.global_position
	if tiro.has_method("configurar"):
		tiro.configurar(dir)
	get_tree().current_scene.add_child(tiro)
