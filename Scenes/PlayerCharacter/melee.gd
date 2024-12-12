extends Area2D
class_name PlayerMelee

@onready var t_MeleeCD:Timer = $MeleeCooldownTimer

#signal variable for player melee to be used by listeners
signal player_melee

var player:Player:
	get:return Player.current
var attrs:Dictionary:
	get:return player.attrs

const MELEE_DELAY__S:float = 0.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	t_MeleeCD.timeout.connect(try_melee)

func _physics_process(_delta:float) -> void:
	if Input.is_action_just_pressed("melee"):
		try_melee()
		
func try_melee() -> void:
	if not t_MeleeCD.is_stopped():
		return
	if not Input.is_action_pressed("melee"):
		$MelColl.debug_color.h = 0.52
		return
	if not player.use_energy():
		return
	$MelColl.debug_color.h = 0
	
	$AnimationPlayer.play("Melee_Anim")
	#emit player_melee signal for listeners
	player_melee.emit()
	t_MeleeCD.start(MELEE_DELAY__S)
	
	for target:Node2D in get_overlapping_bodies():
		if target.is_in_group("enemy"):
			var damage:float = attrs["melee_damage"]
			target.take_damage(damage)
			Player.current.regen_health(damage)
			var knock_dir := Vector2.from_angle(global_rotation) + global_position.direction_to(target.global_position)
			knock_dir = knock_dir.normalized()
			target.take_knockback(knock_dir * attrs["melee_knockback"] * Global.TILE_SIZE)
		if target.is_in_group("enemy_projectile"):
			target.reflect(global_rotation)
