extends Node2D

var intensity = 1.0
#Test AudioStreamPlayer for use in troubleshooting
#@onready var TestAudio = $TestAudio
#reference to Music System AudioStreamPlayer
@onready var MusicSystem = $Music_System
#reference to the MusicSystem stream
#@onready var MusicStreams = MusicSystem.stream
#references to PlayerFootstep AudioStreamPlayer
#reference to the Player Character and Player Character AudioStreamPlayers
@onready var PlayerCharacter = Player.current
#@onready var Shooter:PlayerShooter = Player.current.find_child("Shooter")
#@onready var Melee:PlayerMelee = Shooter.find_child("MeleeDetectorArea")
@onready var PlayerMeleeStream = $Player_Melee
@onready var PlayerShoot = $Player_Shoot
@onready var PlayerFootstep = $Player_Footstep
@onready var PlayerDodgeJump = $Player_Dodge_Jump
@onready var PlayerDodgeLand = $Player_Dodge_Land
@onready var PlayerDamage = $Player_Damage
@onready var PlayerDeath = $Player_Death


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#these lines connect the functions in this script
	#to the signals triggered in the player.gd script
	PlayerCharacter.player_footstep.connect(_on_player_footstep)
	PlayerCharacter.player_dodge_start.connect(_on_player_dodge_start)
	PlayerCharacter.player_dodge_end.connect(_on_player_dodge_end)
	PlayerCharacter.player_damage.connect(_on_player_damage)
	PlayerCharacter.player_death.connect(_on_player_death)
	#Melee.player_melee.connect(_on_player_melee)
	#Shooter.player_shoot.connect(_on_player_shoot)
	PlayerCharacter.In_Combat.connect(_on_combat_start)
	PlayerCharacter.Out_Combat.connect(_on_combat_end)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#this function is triggered every time the player_footstep signal is emitted from the
#player.gd script and plays a footstep in response
func _on_player_footstep() -> void:
	#print("_on_player_footstep was called")
	#By default the AudioStreamPlayer exists at the origin, so we need to set its
	#position to wherever the player is in order for it to be heard correctly
	PlayerFootstep.set_global_position(PlayerCharacter.global_position)
	PlayerFootstep.play()
	
func _on_player_dodge_start() -> void:
	PlayerDodgeJump.set_global_position(PlayerCharacter.global_position)
	PlayerDodgeJump.play()
	
func _on_player_dodge_end() -> void:
	PlayerDodgeLand.set_global_position(PlayerCharacter.global_position)
	PlayerDodgeLand.play()
	
func _on_player_melee() -> void:
	PlayerMeleeStream.set_global_position(PlayerCharacter.global_position)
	PlayerMeleeStream.play()
	
func _on_player_shoot() -> void:
	PlayerShoot.set_global_position(PlayerCharacter.global_position)
	PlayerShoot.play()
	
func _on_player_damage() -> void:
	PlayerDamage.set_global_position(PlayerCharacter.global_position)
	PlayerDamage.play()
	
func _on_player_death() -> void:
	PlayerDeath.set_global_position(PlayerCharacter.global_position)
	PlayerDeath.play()

func _on_combat_start() -> void:
	var playback: AudioStreamPlaybackInteractive = MusicSystem.get_stream_playback()
	playback.switch_to_clip_by_name("Combat_Intro")
	
func _on_combat_end() -> void:
	var playback: AudioStreamPlaybackInteractive = MusicSystem.get_stream_playback()
	playback.switch_to_clip_by_name("Explore")
