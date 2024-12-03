extends Node2D

var intensity = 1.0
#Test AudioStreamPlayer for use in troubleshooting
#@onready var TestAudio = $TestAudio
#reference to Music System AudioStreamPlayer
@onready var MusicSystem = $Music_System
#reference to the MusicSystem stream
#@onready var MusicStreams = MusicSystem.stream
#reference to PlayerFootstep AudioStreamPlayer
@onready var PlayerFootstep = $Player_Footstep
#reference to the Player Character
@onready var PlayerCharacter = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#this line connects the _on_player_footstep_ function in this script
	#to the player_footstep signal triggered in the player.gd script
	PlayerCharacter.player_footstep.connect(_on_player_footstep)

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
	#TestAudio.play()
