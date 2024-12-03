extends CharacterBody2D
class_name Projectile_2

@onready var t_Lifetime:Timer = $BulletLifeTime

const SPEED__TILE_S:float = 10 # base bullet speed, tiles/second

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var speed__tile_s:float = SPEED__TILE_S
	var speed__px_s:float = speed__tile_s * Global.TILE_SIZE
	
	velocity = Vector2.from_angle(global_rotation) * speed__px_s
	
	t_Lifetime.start(speed__tile_s)
	t_Lifetime.timeout.connect(break_bullet)

func init(pos:Vector2, rot:float) -> void:
	global_position = pos
	global_rotation = rot

func _physics_process(delta:float) -> void:
	move_and_slide()

func break_bullet() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(10)
	break_bullet()
