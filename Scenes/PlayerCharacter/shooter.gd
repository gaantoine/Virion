extends Node2D
class_name PlayerShooter

@onready var t_Refire:Timer = $RefireTimer
@onready var PlayerShootAudio = $"../Player_Shoot"

#signal variable for player shooting to be used by audio manager
signal player_shoot

const sc_bullet := preload("res://Animations/VFX/projectile_1.tscn")
const REFIRE__S:float = 0.4 # base refire delay
const BULLET_SPREAD:float = deg_to_rad(3)


var attrs:Dictionary:
	get:return Player.current.attrs
var refire__s:float:
	get:return REFIRE__S / attrs["bullet_firing_rate"]
var bullet_spread:float:
	get:return BULLET_SPREAD / attrs["bullet_accuracy"]


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
	#emit player shoot signal for listeners
	player_shoot.emit()
	#play shoot audio
	PlayerShootAudio.play()
	
	var count:int = attrs["bullet_count"]
	var arc:float = deg_to_rad(attrs["bullet_arc"])
	for i in range(1, count+1):		
		var bullet_angle:float = global_rotation + arc * (i - (count+1)/2.0)
		bullet_angle += randf_range(-bullet_spread, bullet_spread)
		
		var new_bullet:Bullet = sc_bullet.instantiate()
		
		new_bullet.init(attrs, global_position, bullet_angle)
		get_tree().root.add_child(new_bullet)
