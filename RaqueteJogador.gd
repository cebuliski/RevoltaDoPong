extends KinematicBody2D

# Velocidade da raquete em pixels por segundo
export var velocidade = 400 * 50

# Vetor que armazena a direção do movimento (apenas Y, pois o Pong é vertical)
var direcao = Vector2.ZERO

# Função que verifica inputs do jogador a cada frame de física
func _physics_process(delta):
	# Reinicia a direção para 0 antes de verificar o input
	direcao = Vector2.ZERO

	# Para cima
	if Input.is_action_pressed("ui_up"):
		direcao.y = -1 # Y negativo é para cima em 2D

	# Para baixo
	if Input.is_action_pressed("ui_down"):
		direcao.y = 1 # Y positivo é para baixo em 2D
		
	direcao = direcao.normalized()
	
	# Calcula a velocidade final (em pixels por frame)
	var movimento = direcao * velocidade * delta
	
	move_and_slide(movimento, Vector2.ZERO)
