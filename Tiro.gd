extends KinematicBody2D
class_name Tiro

# Velocidade do tiro em pixels por segundo
export var velocidade: float = 500.0

# Direção normalizada do movimento (definida na criação)
var direcao: Vector2 = Vector2.RIGHT

# Referências de nós para notificação
onready var notificador: VisibilityNotifier2D = $VisibilityNotifier2D

# Define a direção do tiro após instanciar
func configurar(nova_direcao: Vector2):
	direcao = nova_direcao.normalized()

# Move o tiro a cada frame de física
func _physics_process(delta: float):
	var movimento := direcao * velocidade * delta
	var colisao: KinematicCollision2D = move_and_collide(movimento)
	
	if colisao:
		_processar_colisao(colisao)

# Conexões iniciais de sinais
func _ready():
	# Remove o tiro ao sair da tela
	if notificador and not notificador.is_connected("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited"):
		# warning-ignore:return_value_discarded
		notificador.connect("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited")

# Saiu da tela remove o tiro (VisualTiro)
func _on_VisibilityNotifier2D_screen_exited():
	# Coloca um nó na fila para exclusão no final do quadro atual
	queue_free()
	
# Função que podemos manipular o que pode ocorrer com o alvo que foi alvejado
# Por exemplo: as caixas azul que irão ser implementadas vai ter o tiro sendo excluído, mas iremos manipular a vida dessas caixas (alienígenas) 
func _processar_colisao(colisao: KinematicCollision2D):
	var corpo := colisao.get_collider()
	
	if corpo.name == "RaqueteJogador":
		queue_free()
	
