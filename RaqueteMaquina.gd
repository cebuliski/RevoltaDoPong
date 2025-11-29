extends KinematicBody2D
class_name RaqueteMaquina

# Velocidade máxima em pixels por segundo que a raquete pode atingir
export var velocidade_max: float = 900.0

# Fator de ganho para o controle proporcional (quanto maior, mais "reativa" a raquete)
# Valores menores (8-10): movimento mais suave e gradual
# Valores maiores (12-15): movimento mais rápido e responsivo
export var ganho_seguimento: float = 10.0

# Altura da raquete para calcular o centro
var altura_raquete: float = 160.0

# Referência à bola (ou ao nó filho que representa o corpo da bola)
# Será usada para acompanhar sua posição Y em tempo real
var alvo_bola: Node2D = null

# Referência direta ao CollisionShape da raquete (para medir e detectar colisões)
onready var colisao_shape: CollisionShape2D = $Colisao


# Calcula a altura da raquete automaticamente
# Aqui, configuramos os parâmetros da raquete e procuramos a bola
func _ready() -> void:
	# Obtemos a altura real da raquete a partir do CollisionShape
	if colisao_shape and colisao_shape.shape is RectangleShape2D:
		var rect_shape = colisao_shape.shape as RectangleShape2D
		altura_raquete = rect_shape.extents.y * 2.0

	# Busca automaticamente o CorpoBola dentro da cena Bola
	# O script supõe que o nó da bola tem um filho chamado "CorpoBola" que representa o KinematicBody2D responsável pelo movimento real
	alvo_bola = get_node_or_null("../Bola/CorpoBola")

func _physics_process(_delta: float) -> void:
	# Se não encontrou a bola, não faz nada, assim evitando problemas de instância
	if alvo_bola == null:
		return

	# Posição vertical (Y) da bola em coordenadas globais
	var y_bola = alvo_bola.global_position.y
	
	# Posição Y atual do centro da raquete
	# Somamos metade da altura porque a posição global da raquete normalmente representa seu canto superior esquerdo, não o centro
	var y_raquete = global_position.y + altura_raquete / 2.0
	
	# Calcula o erro (diferença entre onde a bola está e onde o centro da raquete está)
	var erro = y_bola - y_raquete

	# Controle proporcional: velocidade é proporcional ao erro
	# Quanto maior o erro (distância), maior a velocidade aplicada
	# O ganho_seguimento multiplica o erro para determinar a velocidade
	# O clamp limita a velocidade entre -velocidade_max e +velocidade_max
	# Isso garante movimento suave: quando próximo, move devagar; quando longe, move rápido
	var velocidade_y = clamp(erro * ganho_seguimento, -velocidade_max, velocidade_max)
	
	# Move a raquete respeitando colisões (paredes superior/inferior)
	# move_and_slide já trabalha com pixels por segundo, então não precisa multiplicar por delta
	move_and_slide(Vector2(0, velocidade_y))
