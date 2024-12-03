extends Node2D

var intensity = 1.0
#Test AudioStreamPlayer for use in troubleshooting
#@onready var TestAudio = $TestAudio
#reference to Music System AudioStreamPlayer
@onready var MusicSystem = $Music_System
#reference to the MusicSystem stream
@onready var MusicStreams = MusicSystem.stream
#reference to PlayerFootstep AudioStreamPlayer
@onready var PlayerFootstep = $Player_Footstep
#reference to the Player Character
@onready var PlayerCharacter = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#this line connects the _on_player_footstep_ function in this script
	#to the player_footstep signal triggered in the player.gd script
	PlayerCharacter.player_footstep.connect(_on_player_footstep)
	#set initial volume levels for MusicSystem sub-streams
	#MusicStreams.set_sync_stream_volume(1, -99.0)
	#MusicStreams.set_sync_stream_volume(2, -99.0)
	#MusicStreams.set_sync_stream_volume(3, -99.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#This function updates the intensity variable used to drive active music streams
func updateIntensity(intensityDelta: float) -> void:
	#input check for intensityDelta
	if (typeof(intensityDelta) != TYPE_FLOAT) || (intensityDelta == null):
		#set intensityDelta to zero if the input is incorrect or nonexistent
		intensityDelta = 0.0
	#set local variable to hold original intensity
	var prevIntensity = intensity
	#modify intensity
	intensity += intensityDelta
	#clamp intensity based on number of available streams in Music System
	intensity = clampf(intensity, 1.0, 4.0)
	#check to make sure intensity changed in a meaningful way
	#if it hasn't effectively changed, we don't need to do anything
	if (prevIntensity == intensity):
		pass
	#if intensity has meaningfully changed then we need to pass the new intensity
	#to the rest of the music system
	else:
		updateMusicStreams(intensity)

func updateMusicStreams(intensity) -> void:
	#read intensity and assign stream volumes based on current intensity
	match intensity:
		1.0:
			MusicStreams.set_sync_stream_volume(1, lerpf(-99.0, 0.0, 0.0))
			MusicStreams.set_sync_stream_volume(2, lerpf(-99.0, 0.0, 0.0))
			MusicStreams.set_sync_stream_volume(3, lerpf(-99.0, 0.0, 0.0))
		2.0:
			MusicStreams.set_sync_stream_volume(1, lerpf(-99.0, 0.0, 1.0))
			MusicStreams.set_sync_stream_volume(2, lerpf(-99.0, 0.0, 0.0))
			MusicStreams.set_sync_stream_volume(3, lerpf(-99.0, 0.0, 0.0))
		3.0:
			MusicStreams.set_sync_stream_volume(1, lerpf(-99.0, 0.0, 1.0))
			MusicStreams.set_sync_stream_volume(2, lerpf(-99.0, 0.0, 1.0))
			MusicStreams.set_sync_stream_volume(3, lerpf(-99.0, 0.0, 0.0))
		4.0:
			MusicStreams.set_sync_stream_volume(1, lerpf(-99.0, 0.0, 1.0))
			MusicStreams.set_sync_stream_volume(2, lerpf(-99.0, 0.0, 1.0))
			MusicStreams.set_sync_stream_volume(3, lerpf(-99.0, 0.0, 1.0))
		_:
			MusicStreams.set_sync_stream_volume(0, lerpf(-99.0, 0.0, 0.0))
			MusicStreams.set_sync_stream_volume(1, lerpf(-99.0, 0.0, 0.0))
			MusicStreams.set_sync_stream_volume(2, lerpf(-99.0, 0.0, 0.0))
			MusicStreams.set_sync_stream_volume(3, lerpf(-99.0, 0.0, 0.0))

#this function is triggered every time the player_footstep signal is emitted from the
#player.gd script and plays a footstep in response
func _on_player_footstep() -> void:
	#print("_on_player_footstep was called")
	#By default the AudioStreamPlayer exists at the origin, so we need to set its
	#position to wherever the player is in order for it to be heard correctly
	PlayerFootstep.set_global_position(PlayerCharacter.global_position)
	PlayerFootstep.play()
	#TestAudio.play()

#Implemented input events to manually change Intensity
func _input(event):
	if event.is_action_pressed("Increase_Music_Intensity"):
		updateIntensity(1.0)
	elif event.is_action_pressed("Decrease_Music_Intensity"):
		updateIntensity(-1.0)
