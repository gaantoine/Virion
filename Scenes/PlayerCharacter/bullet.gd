extends CharacterBody2D
class_name Bullet

@onready var t_Lifetime:Timer = $BulletLifeTime
@onready var pierces:int = attrs["bullet_piercing"]

const SPEED__TILE_S:float = 10 # base bullet speed, tiles/second

var attrs:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var speed__tile_s:float = attrs["bullet_speed"] * SPEED__TILE_S
	var speed__px_s:float = speed__tile_s * Global.TILE_SIZE
	
	velocity = Vector2.from_angle(global_rotation) * speed__px_s
	var temp_scale:float = attrs["bullet_size"]
	scale = Vector2(temp_scale, temp_scale)
	
	t_Lifetime.start(attrs["bullet_range"] / speed__tile_s)
	t_Lifetime.timeout.connect(break_bullet)

func init(player_attrs:Dictionary, pos:Vector2, rot:float) -> void:
	global_position = pos
	global_rotation = rot
	attrs = player_attrs

func _physics_process(_delta:float) -> void:
	move_and_slide()


func break_bullet() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var damage:float = attrs["bullet_damage"]
		body.take_damage(damage)
		Player.current.regen_health(damage)
		pierces -= 1
	else:
		pierces = 0
	
	if pierces <= 0:
		break_bullet()
