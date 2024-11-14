extends Node2D
class_name PlayerShooter

@onready var t_Refire:Timer = $RefireTimer

const sc_bullet := preload("res://Animations/VFX/projectile_1.tscn")
const REFIRE__S:float = 0.5 # base refire delay
const MAX_BULLET_DEVIATION__RAD:float = deg_to_rad(2)

var attrs:Dictionary:
	get: return Player.current.attrs

var refire__s:float:
	get:
		return REFIRE__S / attrs["bullet_firing_rate"]

func _ready() -> void:
	t_Refire.timeout.connect(try_shoot)

func _process(_delta:float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		try_shoot()

func try_shoot() -> void:
	if not(t_Refire.is_stopped() and Input.is_action_pressed("shoot")):
		return
		
	t_Refire.start(refire__s)
	var new_bullet:Bullet = sc_bullet.instantiate()
	var fire_angle:float = global_rotation
	
	new_bullet.init(attrs, global_position, fire_angle)
	get_tree().root.add_child(new_bullet)
