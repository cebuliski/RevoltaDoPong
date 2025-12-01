extends KinematicBody2D
class_name RaqueteMaquina

# ===== ENUM DE ESTADOS =====

# Estados possíveis da máquina de estados da RaqueteMaquina
enum Estado {
	ESPERANDO,    # Aguardando a bola entrar no campo de visão
	PERSEGUINDO,  # Seguindo ativamente a bola para rebater
	RECUPERANDO   # Retornando para a posição central
}


# ===== VARIÁVEIS EXPORTADAS =====

# Velocidade máxima em pixels por segundo que a raquete pode atingir
export var velocidade_max: float = 900.0

# Fator de ganho para o controle proporcional (quanto maior, mais "reativa" a raquete)
# Valores menores (8-10): movimento mais suave e gradual
# Valores maiores (12-15): movimento mais rápido e responsivo
export var ganho_seguimento: float = 10.0

# Limite X que define o "campo de visão" da raquete
# Se a bola estiver à esquerda deste valor (X < limite), está no campo de visão
# Padrão: metade esquerda da tela (512 para tela de 1024px)
export var limite_campo_visao: float = 512.0

# Velocidade de recuperação ao retornar para o centro
# Geralmente um pouco mais lenta que a velocidade de perseguição
export var velocidade_recuperacao: float = 600.0

# Tolerância para considerar que chegou na posição central (em pixels)
# Se a distância for menor que isto, considera que já está no centro
export var tolerancia_centro: float = 5.0


# ===== VARIÁVEIS DE ESTADO =====

# Estado atual da máquina de estados
var estado_atual: int = Estado.ESPERANDO

# Posição Y do centro da tela (posição de descanso)
var posicao_central_y: float = 300.0

# Altura da raquete para calcular o centro
var altura_raquete: float = 160.0

# Referência à bola (ou ao nó filho que representa o corpo da bola)
# Será usada para acompanhar sua posição Y em tempo real
var alvo_bola: Node2D = null

# Referência direta ao CollisionShape da raquete (para medir e detectar colisões)
onready var colisao_shape: CollisionShape2D = $Colisao


# Inicialização da raquete e configuração dos parâmetros
func _ready() -> void:
	# Obtemos a altura real da raquete a partir do CollisionShape
	if colisao_shape and colisao_shape.shape is RectangleShape2D:
		var rect_shape = colisao_shape.shape as RectangleShape2D
		altura_raquete = rect_shape.extents.y * 2.0

	# Busca automaticamente o CorpoBola dentro da cena Bola
	# O script supõe que o nó da bola tem um filho chamado "CorpoBola" que representa o KinematicBody2D responsável pelo movimento real
	alvo_bola = get_node_or_null("../Bola/CorpoBola")
	
	# Define a posição central com base no tamanho da viewport
	# Usamos get_viewport_rect() para ser dinâmico
	posicao_central_y = get_viewport_rect().size.y / 2.0
	
	# Inicia no estado ESPERANDO
	mudar_estado(Estado.ESPERANDO)

func _physics_process(_delta: float) -> void:
	# Se não encontrou a bola, não faz nada, assim evitando problemas de instância
	if alvo_bola == null:
		return
	
	# Atualiza a máquina de estados
	atualizar_maquina_estados()
	
	# Executa o comportamento do estado atual
	executar_estado_atual()


# ===== MÁQUINA DE ESTADOS =====

func mudar_estado(novo_estado: int) -> void:
	# Só muda se for um estado diferente
	if estado_atual == novo_estado:
		return
	
	estado_atual = novo_estado


func atualizar_maquina_estados() -> void:
	# Posição X da bola em coordenadas globais
	var x_bola = alvo_bola.global_position.x
	
	# Lógica de transição entre estados baseada na posição da bola
	match estado_atual:
		Estado.ESPERANDO:
			# Transição: ESPERANDO → PERSEGUINDO
			# Se a bola entrou no campo de visão (metade esquerda da tela)
			if x_bola < limite_campo_visao:
				mudar_estado(Estado.PERSEGUINDO)
		
		Estado.PERSEGUINDO:
			# Transição: PERSEGUINDO → RECUPERANDO
			# Se a bola saiu do campo de visão (passou para a direita)
			if x_bola >= limite_campo_visao:
				mudar_estado(Estado.RECUPERANDO)
		
		Estado.RECUPERANDO:
			# Transição: RECUPERANDO → ESPERANDO
			# Se já chegou próximo ao centro (dentro da tolerância)
			var y_raquete = global_position.y + altura_raquete / 2.0
			var distancia_centro = abs(y_raquete - posicao_central_y)
			if distancia_centro <= tolerancia_centro:
				mudar_estado(Estado.ESPERANDO)
			
			# Transição: RECUPERANDO → PERSEGUINDO
			# Se a bola voltou ao campo de visão durante a recuperação
			elif x_bola < limite_campo_visao:
				mudar_estado(Estado.PERSEGUINDO)


func executar_estado_atual() -> void:
	# Executa o comportamento específico de cada estado
	match estado_atual:
		Estado.ESPERANDO:
			executar_esperando()
		
		Estado.PERSEGUINDO:
			executar_perseguindo()
		
		Estado.RECUPERANDO:
			executar_recuperando()


# ===== COMPORTAMENTOS DE CADA ESTADO =====

func executar_esperando() -> void:
	# Estado ESPERANDO: raquete permanece parada na posição central
	# Não realiza movimento ativo
	pass


func executar_perseguindo() -> void:
	# Estado PERSEGUINDO: segue ativamente a posição Y da bola
	
	# Posição vertical (Y) da bola em coordenadas globais
	var y_bola = alvo_bola.global_position.y
	
	# Posição Y atual do centro da raquete
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
	move_and_slide(Vector2(0, velocidade_y))


func executar_recuperando() -> void:
	# Estado RECUPERANDO: retorna suavemente para o centro da tela
	
	# Posição Y atual do centro da raquete
	var y_raquete = global_position.y + altura_raquete / 2.0
	
	# Calcula o erro (diferença entre posição atual e posição central)
	var erro = posicao_central_y - y_raquete
	
	# Usa velocidade de recuperação (geralmente mais lenta que perseguição)
	# Controle proporcional similar ao estado PERSEGUINDO, mas com velocidade diferente
	var velocidade_y = clamp(erro * ganho_seguimento, -velocidade_recuperacao, velocidade_recuperacao)
	
	# Move a raquete respeitando colisões
	move_and_slide(Vector2(0, velocidade_y))
