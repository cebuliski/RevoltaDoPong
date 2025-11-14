extends Node2D
class_name Bola

export(PackedScene) var Tiro

var pode_atirar: bool = false
var bola_no_centro: bool = false
var bateu_raquete_maquina: bool = false

const CENTRO_X: float = 512.0
const TOLERANCIA_CENTRO: float = 4.0

export var velocidade_inicial = 300
export var velocidade_maxima = 800
export var aceleracao_por_colisao = 50
var velocidade = Vector2.ZERO

onready var corpo_bola = $CorpoBola


func _ready():
	randomize()
	iniciar_bola()


func iniciar_bola():
	var angulo = rand_range(-PI/4, PI/4)

	if randf() < 0.5:
		angulo += PI  

	velocidade = Vector2(cos(angulo), sin(angulo)) * velocidade_inicial


func _physics_process(delta):
	var movimento = velocidade * delta
	var colisao: KinematicCollision2D = corpo_bola.move_and_collide(movimento)

	if colisao:
		processar_colisao(colisao)

	var no_centro := abs(corpo_bola.global_position.x - CENTRO_X) <= TOLERANCIA_CENTRO
	if no_centro and not bola_no_centro and bateu_raquete_maquina:

		var direcao_x = 1.0 if velocidade.x >= 0.0 else -1.0
		var dir = Vector2(direcao_x, 0.0)

		habilitar_e_disparar(dir)
		bateu_raquete_maquina = false

	bola_no_centro = no_centro


func processar_colisao(colisao: KinematicCollision2D):
	var normal = colisao.normal
	velocidade = velocidade.bounce(normal)
	velocidade = velocidade.normalized() * min(velocidade.length() + aceleracao_por_colisao, velocidade_maxima)

	var quem_bateu = colisao.get_collider()
	if quem_bateu is RaqueteMaquina:
		bateu_raquete_maquina = true

	if abs(normal.y) > 0.9:
		corpo_bola.position += normal * 2


func habilitar_e_disparar(dir: Vector2):
	if pode_atirar:
		return
	pode_atirar = true
	disparar_tiro(dir)
	pode_atirar = false



func pegar_alvo_vivo() -> Node2D:
	var candidatos = [
		get_tree().current_scene.get_node_or_null("Alvo"),
		get_tree().current_scene.get_node_or_null("Alvo2"),
		get_tree().current_scene.get_node_or_null("Alvo3")
	]

	# Filtra só os que existem e estão vivos
	var vivos: Array = []
	for c in candidatos:
		if c != null and is_instance_valid(c) and c.vida > 0:
			vivos.append(c)

	# Se nenhum vivo → retorna null
	if vivos.size() == 0:
		return null

	return vivos[randi() % vivos.size()]




func disparar_tiro(dir: Vector2):
	if not Tiro:
		return

	var tiro = Tiro.instance()
	tiro.global_position = corpo_bola.global_position

	var alvo = pegar_alvo_vivo()

	if tiro.has_method("configurar"):
		tiro.configurar(alvo)

	get_tree().current_scene.add_child(tiro)
