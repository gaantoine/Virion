extends CharacterBody2D

enum MOVEMODE {
	DASHING,
	DECELERATING,
	WAITING,
}

@export var dash_speed = 900 # Speed of the dash
@export var dash_duration = 0.4 # Duration of the dash (in seconds)
@export var dash_cooldown = 2.0 # Cooldown between dashes
@export var deceleration = 3000

var dash_direction = Vector2.ZERO
var dash_timer = 0.0
var current_speed = 0.0

var player
var state = MOVEMODE.WAITING

func _ready():
	player = Player.current
	$AttackCooldownTimer.timeout.connect(_on_Timer_timeout)

func _physics_process(delta: float) -> void:
	match state:
		MOVEMODE.DASHING:
			dash_timer += delta
			
			global_position += dash_direction * dash_speed * delta
			
			if dash_timer >= dash_duration:
				state = MOVEMODE.DECELERATING
		MOVEMODE.DECELERATING:
			current_speed = max(current_speed - deceleration * delta, 0)
			velocity = dash_direction * current_speed
			move_and_slide()
			
			if current_speed <= 0:
				state = MOVEMODE.WAITING
				$AttackCooldownTimer.start(dash_cooldown)
		MOVEMODE.WAITING:
			velocity = Vector2.ZERO
			move_and_slide()

func start_dashing():
	state = MOVEMODE.DASHING
	dash_direction = (player.position - global_position).normalized()
	current_speed = dash_speed
	dash_timer = 0.0

func stop_dashing():
	state = MOVEMODE.DECELERATING
	$AttackCooldownTimer.start(dash_cooldown)

func _on_Timer_timeout():
	start_dashing()
