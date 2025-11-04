extends KinematicBody2D

# Velocidade da raquete em pixels por segundo
export var velocidade = 400 * 50

# Vetor que armazena a direção do movimento (apenas Y, pois o Pong é vertical)
var direcao = Vector2.ZERO

# Função que verifica inputs do jogador a cada frame de física
func _physics_process(delta):
	# Reinicia a direção para 0 antes de verificar o input
	direcao = Vector2.ZERO

	# --- Lógica de Input e Direção ---

	# Para cima
	# is_action_pressed("ui_up") é o input padrão para cima
	if Input.is_action_pressed("ui_up"):
		direcao.y = -1 # Y negativo é para cima em 2D

	# Para baixo
	# is_action_pressed("ui_down") é o input padrão para baixo
	if Input.is_action_pressed("ui_down"):
		direcao.y = 1 # Y positivo é para baixo em 2D
		
	# --- Movimentação ---
	
	# Normaliza a direção se for diferente de zero.
	# Isso é bom para garantir que o vetor tenha um comprimento máximo de 1
	# caso você use inputs combinados (embora no Pong não seja o caso).
	direcao = direcao.normalized()
	
	# Calcula a velocidade final (em pixels por frame)
	var movimento = direcao * velocidade * delta
	
	# move_and_slide() é a função principal para mover o KinematicBody2D,
	# ele lida com a colisão automaticamente.
	# O segundo argumento (Vector2.UP) é o "vetor de chão",
	# mas em um jogo como o Pong, é seguro usar Vector2.ZERO.
	# No Godot 3.5, move_and_slide() requer um argumento de vetor de chão,
	# usaremos Vector2.ZERO para 2D puro sem gravidade.
	move_and_slide(movimento, Vector2.ZERO)
