extends KinematicBody2D
class_name Tiro

export var velocidade: float = 500.0

var alvo_node: Node2D = null
var direcao: Vector2 = Vector2.RIGHT
onready var notificador: VisibilityNotifier2D = $VisibilityNotifier2D


# ============================================================
# 🔥 ALTERADO: agora recebe o Node2D do alvo
# ============================================================
func configurar(novo_alvo: Node2D):
	alvo_node = novo_alvo

	if alvo_node and is_instance_valid(alvo_node):
		direcao = (alvo_node.global_position - global_position).normalized()


func _physics_process(delta: float):
	if alvo_node and is_instance_valid(alvo_node):
		direcao = (alvo_node.global_position - global_position).normalized()

	var movimento := direcao * velocidade * delta
	var colisao: KinematicCollision2D = move_and_collide(movimento)

	if colisao:
		_processar_colisao(colisao)


func _ready():
	if notificador and not notificador.is_connected("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited"):
		notificador.connect("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited")


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	

func _processar_colisao(colisao: KinematicCollision2D):
	var corpo := colisao.get_collider()

	if corpo.name == "RaqueteJogador" or corpo.name == "Alvo" or corpo.name == "Alvo2" or corpo.name == "Alvo3":
		queue_free()
