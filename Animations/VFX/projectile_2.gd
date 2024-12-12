extends CharacterBody2D
class_name Projectile_2

@onready var animation_tree : AnimationTree = $Projectile_AnimationTree
@onready var t_Lifetime:Timer = $BulletLifeTime

const SPEED__TILE_S:float = 10 # base bullet speed, tiles/second

var target_group:String = "player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true
	start_projectile()
	
	t_Lifetime.timeout.connect(break_bullet)

func start_projectile() -> void:
	var speed__tile_s:float = SPEED__TILE_S
	var speed__px_s:float = speed__tile_s * Global.TILE_SIZE
	
	velocity = Vector2.from_angle(global_rotation) * speed__px_s
	
	t_Lifetime.start(10 / speed__tile_s)

func init(pos:Vector2, rot:float) -> void:
	global_position = pos
	global_rotation = rot

func _physics_process(delta:float) -> void:
	move_and_slide()

func break_bullet() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group):
		body.take_damage(10)
	break_bullet()

func reflect(heading:float) -> void:
	target_group = "enemy"
	global_rotation = heading - PI/2
	start_projectile()
	$Area2D.set_collision_mask_value(6, false)
	$Area2D.set_collision_mask_value(9, true)
	
