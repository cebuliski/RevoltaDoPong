extends Node2D

# Velocidade inicial da bola em pixels por segundo
export var velocidade_inicial = 300

# Velocidade máxima da bola para evitar que fique muito rápida
export var velocidade_maxima = 800

# Aceleração da bola a cada colisão (para aumentar a dificuldade)
export var aceleracao_por_colisao = 50

# Vetor de velocidade da bola
var velocidade = Vector2.ZERO

# Referência para o campo de jogo (para detectar limites)
var limite_campo = Vector2(1024, 600)

# Referência para o corpo da bola (KinematicBody2D)
onready var corpo_bola = $CorpoBola

# Função chamada quando o nó entra na árvore da cena
func _ready():
	# Inicializa o gerador de números aleatórios com uma semente (seed) baseado no relógio do sistema
	randomize()
	# Inicia a bola com uma direção aleatória
	iniciar_bola()

# Função que inicia a bola com direção aleatória
func iniciar_bola():
	# Gera um ângulo aleatório entre -45 e 45 graus
	var angulo = rand_range(-PI/4, PI/4)
	
	# Adiciona um pouco de aleatoriedade na direção horizontal
	# para evitar que a bola sempre vá para o mesmo lado
	if randf() < 0.5:
		angulo += PI  # Inverte a direção horizontal
	
	# Define a velocidade inicial baseada no ângulo
	velocidade = Vector2(cos(angulo), sin(angulo)) * velocidade_inicial

# Função de física chamada a cada frame
func _physics_process(delta):
	# Move a bola usando a velocidade atual
	var movimento = velocidade * delta
	var colisao = corpo_bola.move_and_collide(movimento)
	
	# Se houve colisão, processa o rebote
	if colisao:
		processar_colisao(colisao)

# Função que processa as colisões da bola
func processar_colisao(colisao):
	# Obtém a normal da colisão (direção perpendicular à superfície)
	var normal = colisao.normal
	
	# Reflete a velocidade da bola na superfície de colisão
	velocidade = velocidade.bounce(normal)
	
	# Aumenta ligeiramente a velocidade para tornar o jogo mais emocionante
	velocidade = velocidade.normalized() * min(velocidade.length() + aceleracao_por_colisao, velocidade_maxima)
	
	# Verifica se a bola colidiu com as paredes superior ou inferior
	if abs(normal.y) > 0.9:  # Colisão com parede superior/inferior
		# Ajusta a posição da bola para evitar que fique "grudada" na parede
		corpo_bola.position += normal * 2
