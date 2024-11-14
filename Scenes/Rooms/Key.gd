extends Node2D

var player = null 

func _ready():

    pass

func follow_player():
    if player:
        global_position = player.global_position
