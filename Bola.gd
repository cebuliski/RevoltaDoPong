extends Node2D
class_name Bola

export(PackedScene) var Tiro

# Sinal emitido quando a bola bate na parede OU passa da raquete (causa derrota)
signal bateu_parede_game_over

var pode_atirar: bool = false
var bola_no_centro: bool = false
var bateu_raquete_maquina: bool = false
var jogo_ativo: bool = true

const CENTRO_X: float = 512.0
const TOLERANCIA_CENTRO: float = 4.0

# NOVO: Se a bola passar desta posição X, é Game Over (Segurança caso não bata na parede)
const LIMITE_DIREITA_GAMEOVER: float = 1060.0 

export var velocidade_inicial = 300
export var velocidade_maxima = 300 #800
export var aceleracao_por_colisao = 50
var velocidade = Vector2.ZERO

onready var corpo_bola = $CorpoBola


func _ready():
	randomize()
	iniciar_bola()


func iniciar_bola():
	jogo_ativo = true
	var angulo = rand_range(-PI/4, PI/4)

	if randf() < 0.5:
		angulo += PI  

	velocidade = Vector2(cos(angulo), sin(angulo)) * velocidade_inicial


func _physics_process(delta):
	# Se o jogo não está ativo (já deu game over), para de processar
	if not jogo_ativo:
		return

	var movimento = velocidade * delta
	var colisao: KinematicCollision2D = corpo_bola.move_and_collide(movimento)

	if colisao:
		processar_colisao(colisao)

	if corpo_bola.global_position.x > LIMITE_DIREITA_GAMEOVER:
		disparar_game_over()

	var no_centro := abs(corpo_bola.global_position.x - CENTRO_X) <= TOLERANCIA_CENTRO
	if no_centro and not bola_no_centro and bateu_raquete_maquina:

		habilitar_e_disparar()
		bateu_raquete_maquina = false

	bola_no_centro = no_centro


func processar_colisao(colisao: KinematicCollision2D):
	var normal = colisao.normal
	
	# Verifica se bateu na parede que causa Game Over. Se bateu, o jogo termina.
	var quem_bateu = colisao.get_collider()
	if quem_bateu and quem_bateu.is_in_group("parede_game_over"):
		disparar_game_over()
		return
	
	velocidade = velocidade.bounce(normal)
	velocidade = velocidade.normalized() * min(velocidade.length() + aceleracao_por_colisao, velocidade_maxima)

	if quem_bateu is RaqueteMaquina:
		bateu_raquete_maquina = true

	if abs(normal.y) > 0.9:
		corpo_bola.position += normal * 2

# Função auxiliar para garantir que o sinal só seja emitido uma vez
func disparar_game_over():
	if jogo_ativo:
		jogo_ativo = false
		emit_signal("bateu_parede_game_over")

func habilitar_e_disparar():
	if pode_atirar:
		return
	pode_atirar = true
	disparar_tiro()
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

	if vivos.size() == 0:
		return null

	return vivos[randi() % vivos.size()]


func disparar_tiro():
	if not Tiro:
		return

	var tiro = Tiro.instance()
	tiro.global_position = corpo_bola.global_position

	var alvo = pegar_alvo_vivo()

	if tiro.has_method("configurar"):
		tiro.configurar(alvo)

	get_tree().current_scene.add_child(tiro)
